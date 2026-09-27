import '../../domain/entities/quran_reciter.dart';

class QuranReciterModel extends QuranReciter {
  const QuranReciterModel({
    required super.identifier,
    required super.name,
    required super.englishName,
    super.bitrate = 128,
  });
}

const List<QuranReciterModel> quranReciters = [
  // QuranReciterModel(
  //   identifier: 'ar.abdullahbasfar',
  //   name: 'Abdullah Basfar',
  //   englishName: 'Abdullah Basfar',
  //   bitrate: 128,
  // ),

  // QuranReciterModel(
  //   identifier: 'ar.abdurrahmaansudais',
  //   name: 'Abdulrahman Al-Sudais',
  //   englishName: 'Abdurrahmaan As-Sudais',
  //   bitrate: 192,
  // ),

  // QuranReciterModel(
  //   identifier: 'ar.abdulsamad',
  //   name: 'Abdul Basit Abdul Samad',
  //   englishName: 'Abdul Samad',
  //   bitrate: 128,
  // ),

  // QuranReciterModel(
  //   identifier: 'ar.shaatree',
  //   name: 'Abu Bakr Al-Shatri',
  //   englishName: 'Abu Bakr Ash-Shaatree',
  //   bitrate: 128,
  // ),

  QuranReciterModel(
    identifier: 'ar.ahmedajamy',
    name: 'أحمد بن علي العجمي',
    englishName: 'Ahmed ibn Ali al-Ajamy',
    bitrate: 128,
  ),

  QuranReciterModel(
    identifier: 'ar.alafasy',
    name: 'مشاري راشد العفاسي',
    englishName: 'Mishary Rashid Alafasy',
    bitrate: 128,
  ),

  // QuranReciterModel(
  //   identifier: 'ar.hanirifai',
  //   name: 'Hani Al-Rifai',
  //   englishName: 'Hani Rifai',
  //   bitrate: 128,
  // ),

  QuranReciterModel(
    identifier: 'ar.husary',
    name: 'محمود خليل الحصري',
    englishName: 'Mahmoud Khalil Al-Husary',
    bitrate: 128,
  ),

  QuranReciterModel(
    identifier: 'ar.hudhaify',
    name: 'علي بن عبدالرحمن الحذيفي',
    englishName: 'Ali Al-Hudhaify',
    bitrate: 128,
  ),

  // QuranReciterModel(
  //   identifier: 'ar.ibrahimakhbar',
  //   name: 'Ibrahim Al-Akhdar',
  //   englishName: 'Ibrahim Akhdar',
  //   bitrate: 128,
  // ),

  QuranReciterModel(
    identifier: 'ar.mahermuaiqly',
    name: 'ماهر المعيقلي',
    englishName: 'Maher Al Muaiqly',
    bitrate: 128,
  ),

  QuranReciterModel(
    identifier: 'ar.muhammadayyoub',
    name: 'محمد أيوب',
    englishName: 'Muhammad Ayyoub',
    bitrate: 128,
  ),

  QuranReciterModel(
    identifier: 'ar.muhammadjibreel',
    name: 'محمد جبريل',
    englishName: 'Muhammad Jibreel',
    bitrate: 128,
  ),

  // QuranReciterModel(
  //   identifier: 'ar.saoodshuraym',
  //   name: 'Saud Al-Shuraim',
  //   englishName: 'Saood Ash-Shuraym',
  //   bitrate: 128,
  // ),

  // QuranReciterModel(
  //   identifier: 'ar.parhizgar',
  //   name: 'Shahriar Parhizgar',
  //   englishName: 'Parhizgar',
  //   bitrate: 64,
  // ),
  //
  // QuranReciterModel(
  //   identifier: 'ar.aymanswoaid',
  //   name: 'Ayman Suwayd',
  //   englishName: 'Ayman Sowaid',
  //   bitrate: 128,
  // ),
];