import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qcf_quran/qcf_quran.dart';

import '../../../../core/data/quran/quran_helpers.dart';
import '../../../../core/services/ayah_audio_service.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/quran_translation.dart';
import '../../domain/entities/quran_translation_resource.dart';
import '../../domain/usecases/get_ayah_audio_url.dart';
import '../../domain/usecases/get_chapter_translation.dart';
import '../../domain/usecases/get_translation_resources.dart';
import '../widgets/mushaf_page.dart';

class QuranTranslationPage extends StatefulWidget {
  final int initialSurahNumber;
  final int? initialAyahNumber;

  const QuranTranslationPage({
    super.key,
    this.initialSurahNumber = 1,
    this.initialAyahNumber,
  });

  @override
  State<QuranTranslationPage> createState() => _QuranTranslationPageState();
}

class _QuranTranslationPageState extends State<QuranTranslationPage> {
  // Theme colors matching Noor app
  static const Color _bgWarmColor = Color(0xFFFCF5D7);
  static const Color _cardBgColor = Color(0xFFFFFDF5);
  static const Color _primaryBrown = Color(0xFF8B5A2B);
  static const Color _accentTeal = Color(0xFF176B5B);
  static const Color _chipBgColor = Color(0xFFF3E5C8);

  late int _currentSurah;
  late final GetChapterTranslation _getChapterTranslation;
  late final GetTranslationResources _getTranslationResources;
  late final AyahAudioService _audioService;
  late final GetAyahAudioUrl _getAyahAudioUrl;

  final ScrollController _scrollController = ScrollController();

  List<QuranTranslationResource> _resources = [];
  QuranTranslationResource? _selectedResource;

  bool _isLoading = false;
  String? _errorMessage;

  // In-memory cache: "surah:resourceId" -> translations
  final Map<String, List<QuranTranslation>> _translationCache = {};

  List<QuranTranslation> _currentTranslations = [];

  // Audio state
  StreamSubscription<PlayerState>? _playerSub;
  int? _currentlyPlayingGlobalAyah;
  bool _isPlayingAudio = false;

  // English transliterated names of Surahs
  static const List<String> _surahEnglishNames = [
    'Al-Faatiha', 'Al-Baqarah', 'Aal-i-Imraan', 'An-Nisaa', 'Al-Maaida',
    'Al-An\'aam', 'Al-A\'raaf', 'Al-Anfaal', 'At-Tawba', 'Yunus',
    'Hud', 'Yusuf', 'Ar-Ra\'d', 'Ibrahim', 'Al-Hijr',
    'An-Nahl', 'Al-Israa', 'Al-Kahf', 'Maryam', 'Taa-Haa',
    'Al-Anbiyaa', 'Al-Hajj', 'Al-Mu\'minoon', 'An-Noor', 'Al-Furqaan',
    'Ash-Shu\'araa', 'An-Naml', 'Al-Qasas', 'Al-Ankaboot', 'Ar-Room',
    'Luqman', 'As-Sajda', 'Al-Ahzaab', 'Saba', 'Faatir',
    'Yaseen', 'As-Saaffaat', 'Saad', 'Az-Zumar', 'Ghafir',
    'Fussilat', 'Ash-Shura', 'Az-Zukhruf', 'Ad-Dukhaan', 'Al-Jaathiya',
    'Al-Ahqaf', 'Muhammad', 'Al-Fath', 'Al-Hujuraat', 'Qaaf',
    'Adh-Dhaariyaat', 'At-Toor', 'An-Najm', 'Al-Qamar', 'Ar-Rahmaan',
    'Al-Waaqi\'a', 'Al-Hadeed', 'Al-Mujaadila', 'Al-Hashr', 'Al-Mumtahana',
    'As-Saff', 'Al-Jumu\'a', 'Al-Munaafiqoon', 'At-Taghaabun', 'At-Talaaq',
    'At-Tahreem', 'Al-Mulk', 'Al-Qalam', 'Al-Haaqqa', 'Al-Ma\'aarij',
    'Nooh', 'Al-Jinn', 'Al-Muzzammil', 'Al-Muddaththir', 'Al-Qiyaama',
    'Al-Insaan', 'Al-Mursalaat', 'An-Naba', 'An-Naazi\'aat', 'Abasa',
    'At-Takweer', 'Al-Infitaar', 'Al-Mutaffifeen', 'Al-Inshiqaaq', 'Al-Burooj',
    'At-Taariq', 'Al-A\'laa', 'Al-Ghaashiya', 'Al-Fajr', 'Al-Balad',
    'Ash-Shams', 'Al-Lail', 'Ad-Duhaa', 'Ash-Sharh', 'At-Teen',
    'Al-Alaq', 'Al-Qadr', 'Al-Bayyina', 'Az-Zalzala', 'Al-Aadiyaat',
    'Al-Qaari\'a', 'At-Takaathur', 'Al-Asr', 'Al-Humaza', 'Al-Feel',
    'Quraish', 'Al-Maa\'oon', 'Al-Kawthar', 'Al-Kaafiroon', 'An-Nasr',
    'Al-Masad', 'Al-Ikhlaas', 'Al-Falaq', 'An-Naas',
  ];

  static const List<bool> _meccanSurahs = [
    true, false, false, false, false, true, true, false, false, true,
    true, true, false, true, true, true, true, true, true, true,
    true, false, true, false, true, true, true, true, true, true,
    true, true, true, false, true, true, true, true, true, true,
    true, true, true, true, true, true, false, false, false, true,
    true, true, true, true, false, true, false, false, false, false,
    false, false, false, false, false, false, true, true, true, true,
    true, true, true, true, false, true, true, true, true, true,
    true, true, true, true, true, true, true, true, true, true,
    true, true, true, true, true, true, true, false, false, true,
    true, true, true, true, true, true, true, true, true, true,
    false, true, true, true, true,
  ];

  @override
  void initState() {
    super.initState();
    _currentSurah = widget.initialSurahNumber.clamp(1, 114);
    _getChapterTranslation = sl<GetChapterTranslation>();
    _getTranslationResources = sl<GetTranslationResources>();
    _audioService = sl<AyahAudioService>();
    _getAyahAudioUrl = sl<GetAyahAudioUrl>();

    _initAudioListener();
    _loadResourcesAndChapter();
  }

  void _initAudioListener() {
    _playerSub = _audioService.playerStateStream.listen((state) {
      if (!mounted) return;
      final playing = state.playing && state.processingState != ProcessingState.completed;
      setState(() {
        _isPlayingAudio = playing;
        if (!playing && state.processingState == ProcessingState.completed) {
          _currentlyPlayingGlobalAyah = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _playerSub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadResourcesAndChapter() async {
    try {
      final resources = await _getTranslationResources();
      if (!mounted) return;

      QuranTranslationResource? selected;
      // Default to Saheeh International (id: 20)
      for (final r in resources) {
        if (r.id == 20) {
          selected = r;
          break;
        }
      }
      selected ??= resources.isNotEmpty ? resources.first : null;

      setState(() {
        _resources = resources;
        _selectedResource = selected;
      });

      await _fetchChapterTranslation(_currentSurah, selected?.id ?? 20);
    } catch (_) {
      // Fallback
      if (!mounted) return;
      await _fetchChapterTranslation(_currentSurah, 20);
    }
  }

  Future<void> _fetchChapterTranslation(int surah, int resourceId) async {
    final cacheKey = '$surah:$resourceId';

    if (_translationCache.containsKey(cacheKey)) {
      setState(() {
        _currentTranslations = _translationCache[cacheKey]!;
        _isLoading = false;
        _errorMessage = null;
      });
      _scrollToInitialAyahIfNeeded();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final translations = await _getChapterTranslation(
        chapterNumber: surah,
        resourceId: resourceId,
      );

      if (!mounted) return;

      _translationCache[cacheKey] = translations;

      setState(() {
        _currentTranslations = translations;
        _isLoading = false;
        _errorMessage = null;
      });

      _scrollToInitialAyahIfNeeded();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر تحميل الترجمة. يرجى التأكد من اتصال الإنترنت والمحاولة ثانية.';
      });
    }
  }

  void _scrollToInitialAyahIfNeeded() {
    if (widget.initialAyahNumber != null && widget.initialAyahNumber! > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;
        final targetIndex = widget.initialAyahNumber! - 1;
        // Approximate scroll position
        final targetOffset = targetIndex * 180.0;
        _scrollController.animateTo(
          targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _onSurahChanged(int newSurah) {
    if (newSurah < 1 || newSurah > 114 || newSurah == _currentSurah) return;
    setState(() {
      _currentSurah = newSurah;
    });
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
    }
    _fetchChapterTranslation(newSurah, _selectedResource?.id ?? 20);
  }

  void _onTranslatorChanged(QuranTranslationResource resource) {
    if (_selectedResource?.id == resource.id) return;
    setState(() {
      _selectedResource = resource;
    });
    _fetchChapterTranslation(_currentSurah, resource.id);
  }

  Future<void> _togglePlayAyah(int ayahNumber) async {
    final globalAyah = getGlobalAyahNumber(_currentSurah, ayahNumber);

    if (_currentlyPlayingGlobalAyah == globalAyah && _isPlayingAudio) {
      await _audioService.pause();
      return;
    }

    if (_currentlyPlayingGlobalAyah == globalAyah && !_isPlayingAudio) {
      await _audioService.resume();
      return;
    }

    try {
      final reciter = _audioService.currentReciter ?? 'ar.alafasy';
      final url = _getAyahAudioUrl(
        reciterIdentifier: reciter,
        globalAyahNumber: globalAyah,
      );

      setState(() {
        _currentlyPlayingGlobalAyah = globalAyah;
      });

      await _audioService.playUrl(
        audioUrl: url,
        reciterIdentifier: reciter,
        globalAyahNumber: globalAyah,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تشغيل الصوت، تأكد من الاتصال بالإنترنت'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _copyAyah(int ayahNumber, String arabicText, String translationText) {
    final surahName = getSurahNameArabic(_currentSurah);
    final englishSurah = _surahEnglishNames[_currentSurah - 1];
    final translator = _selectedResource?.name ?? 'Saheeh International';

    final textToCopy =
        '$arabicText ﴿$ayahNumber﴾\n\n'
        '"$translationText"\n\n'
        '— [$surahName ($englishSurah) $_currentSurah:$ayahNumber] ($translator)';

    Clipboard.setData(ClipboardData(text: textToCopy));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _primaryBrown,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'تم نسخ الآية والترجمة ($ayahNumber)',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openInTraditionalMushaf([int ayahNumber = 1]) {
    final pageNumber = getPageNumber(_currentSurah, ayahNumber);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MushafPage(startPage: pageNumber),
      ),
    );
  }

  void _showSurahPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _bgWarmColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollSheet) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _primaryBrown.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'اختر السورة للترجمة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _primaryBrown,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: _primaryBrown),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollSheet,
                    itemCount: 114,
                    itemBuilder: (context, index) {
                      final surahNum = index + 1;
                      final isSelected = surahNum == _currentSurah;
                      final name = getSurahNameArabic(surahNum);
                      final english = _surahEnglishNames[index];
                      final isMeccan = _meccanSurahs[index];
                      final verses = getVerseCount(surahNum);

                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: _chipBgColor.withValues(alpha: 0.5),
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? _primaryBrown : _chipBgColor,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$surahNum',
                            style: TextStyle(
                              color: isSelected ? Colors.white : _primaryBrown,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        title: Text(
                          name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected ? _primaryBrown : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          '$english • ${isMeccan ? "مكية" : "مدنية"} ($verses آية)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: _primaryBrown)
                            : null,
                        onTap: () {
                          Navigator.pop(ctx);
                          _onSurahChanged(surahNum);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTranslatorPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _bgWarmColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _primaryBrown.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Select English Translation / اختر المترجم',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _primaryBrown,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select your preferred English translation of the Holy Quran:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _resources.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final res = _resources[index];
                      final isSelected = res.id == _selectedResource?.id;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        leading: Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? _primaryBrown : Colors.black45,
                        ),
                        title: Text(
                          res.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? _primaryBrown : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          res.authorName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          _onTranslatorChanged(res);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final surahName = getSurahNameArabic(_currentSurah);
    final englishName = _surahEnglishNames[_currentSurah - 1];
    final totalVerses = getVerseCount(_currentSurah);
    final isMeccan = _meccanSurahs[_currentSurah - 1];
    final pageNumber = getPageNumber(_currentSurah, 1);

    return Scaffold(
      backgroundColor: _bgWarmColor,
      appBar: AppBar(
        backgroundColor: _bgWarmColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: _primaryBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _showSurahPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _chipBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _primaryBrown.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.keyboard_arrow_down, size: 18, color: _primaryBrown),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    surahName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _primaryBrown,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          // Translator selector button
          IconButton(
            tooltip: 'تغيير المترجم / Change Translator',
            icon: const Icon(Icons.translate, color: _primaryBrown, size: 22),
            onPressed: _showTranslatorPicker,
          ),
          // Traditional Mushaf Page View
          IconButton(
            tooltip: 'عرض صفحات المصحف',
            icon: const Icon(Icons.menu_book_rounded, color: _primaryBrown, size: 22),
            onPressed: () => _openInTraditionalMushaf(1),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Info Banner: Translator chip + Surah navigation strip
          _buildTopNavigationStrip(pageNumber, isMeccan, totalVerses, englishName),

          // Main Verses & Translation Content
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState()
                    : _buildVersesList(totalVerses),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavigationStrip(
    int pageNumber,
    bool isMeccan,
    int totalVerses,
    String englishName,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _chipBgColor.withValues(alpha: 0.4),
        border: Border(
          bottom: BorderSide(
            color: _primaryBrown.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Prev Surah Button
          IconButton(
            icon: const Icon(Icons.skip_previous_rounded, size: 22, color: _primaryBrown),
            tooltip: 'السورة السابقة',
            onPressed: _currentSurah > 1 ? () => _onSurahChanged(_currentSurah - 1) : null,
          ),

          // Translation details
          Expanded(
            child: InkWell(
              onTap: _showTranslatorPicker,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ترجمة: ${_selectedResource?.name ?? "Saheeh International"}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _accentTeal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$englishName • ${isMeccan ? "مكية" : "مدنية"} • $totalVerses آية • ص $pageNumber',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Next Surah Button
          IconButton(
            icon: const Icon(Icons.skip_next_rounded, size: 22, color: _primaryBrown),
            tooltip: 'السورة التالية',
            onPressed: _currentSurah < 114 ? () => _onSurahChanged(_currentSurah + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildVersesList(int totalVerses) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      itemCount: totalVerses + 1, // 0 is header / Basmalah
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildSurahHeader();
        }

        final ayahNumber = index; // 1-indexed ayah
        final arabicVerse = getVerse(_currentSurah, ayahNumber);

        // Match translation from list if available
        String translationText = '';
        if (_currentTranslations.isNotEmpty) {
          // If items have ayahNumber, find it, otherwise by index
          if (ayahNumber - 1 < _currentTranslations.length) {
            translationText = _currentTranslations[ayahNumber - 1].text;
          }
        }

        final globalAyah = getGlobalAyahNumber(_currentSurah, ayahNumber);
        final isPlayingThis = _currentlyPlayingGlobalAyah == globalAyah && _isPlayingAudio;

        return _buildAyahCard(
          ayahNumber: ayahNumber,
          arabicVerse: arabicVerse,
          translationText: translationText,
          isPlaying: isPlayingThis,
        );
      },
    );
  }

  Widget _buildSurahHeader() {
    final surahName = getSurahNameArabic(_currentSurah);
    final englishName = _surahEnglishNames[_currentSurah - 1];
    final isMeccan = _meccanSurahs[_currentSurah - 1];
    final totalVerses = getVerseCount(_currentSurah);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: _chipBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _primaryBrown.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Surah Title Badge
          Text(
            surahName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _primaryBrown,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$englishName • ${isMeccan ? "Makkiyah" : "Madaniyah"} • $totalVerses Verses',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _accentTeal.withValues(alpha: 0.9),
            ),
          ),

          // Basmalah Banner (except Surah At-Tawbah (9) and Surah Al-Fatiha (1, where it is ayah 1))
          if (_currentSurah != 9 && _currentSurah != 1) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _cardBgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _primaryBrown.withValues(alpha: 0.2),
                ),
              ),
              child: const Text(
                'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryBrown,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAyahCard({
    required int ayahNumber,
    required String arabicVerse,
    required String translationText,
    required bool isPlaying,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPlaying
              ? _accentTeal
              : _primaryBrown.withValues(alpha: 0.18),
          width: isPlaying ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPlaying
                ? _accentTeal.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top action bar of Ayah
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ayah Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPlaying ? _accentTeal : _chipBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPlaying ? _accentTeal : _primaryBrown.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '$_currentSurah:$ayahNumber',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPlaying ? Colors.white : _primaryBrown,
                    ),
                  ),
                ),

                // Quick Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Audio Play/Pause
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled : Icons.play_circle_outline,
                        color: isPlaying ? _accentTeal : _primaryBrown,
                        size: 24,
                      ),
                      tooltip: isPlaying ? 'إيقاف مؤقت' : 'استماع للتلاوة',
                      onPressed: () => _togglePlayAyah(ayahNumber),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),

                    // Copy Ayah & Translation
                    IconButton(
                      icon: const Icon(
                        Icons.copy_rounded,
                        color: _primaryBrown,
                        size: 20,
                      ),
                      tooltip: 'نسخ الآية والترجمة',
                      onPressed: () => _copyAyah(ayahNumber, arabicVerse, translationText),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),

                    // View in Mushaf Page
                    IconButton(
                      icon: const Icon(
                        Icons.open_in_new_rounded,
                        color: _primaryBrown,
                        size: 19,
                      ),
                      tooltip: 'عرض في صفحة المصحف',
                      onPressed: () => _openInTraditionalMushaf(ayahNumber),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Arabic Verse
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                '$arabicVerse ﴿$ayahNumber﴾',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 21,
                  height: 1.9,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E1E1E),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Divider between Arabic and English
            Divider(
              color: _primaryBrown.withValues(alpha: 0.12),
              height: 1,
            ),

            const SizedBox(height: 12),

            // English Translation Text
            Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translationText.isNotEmpty
                        ? translationText
                        : 'Loading translation...',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 15.5,
                      height: 1.6,
                      color: translationText.isNotEmpty
                          ? const Color(0xFF2C3E50)
                          : Colors.black38,
                      fontStyle: translationText.isNotEmpty
                          ? FontStyle.normal
                          : FontStyle.italic,
                    ),
                  ),
                  if (translationText.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      '— ${_selectedResource?.name ?? "Saheeh International"}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black.withValues(alpha: 0.45),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_primaryBrown),
          ),
          SizedBox(height: 16),
          Text(
            'جاري تحميل الترجمة والآيات...',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _primaryBrown,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 54,
              color: _primaryBrown,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'حدث خطأ في تحميل الترجمة',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _fetchChapterTranslation(
                _currentSurah,
                _selectedResource?.id ?? 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
