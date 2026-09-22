// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';
// import '../../domain/entities/dhikr_entity.dart';
// import '../../domain/usecases/get_adhkar.dart';
//
// part 'adhkar_event.dart';
// part 'adhkar_state.dart';
//
// class AdhkarBloc extends Bloc<AdhkarEvent, AdhkarState> {
//   final GetAdhkar getAdhkar;
//
//   AdhkarBloc(this.getAdhkar) : super(const AdhkarInitial()) {
//     on<LoadAdhkar>((event, emit) async {
//       print('📿 LoadAdhkar Event');
//
//       emit(const AdhkarLoading());
//
//       try {
//         final result = await getAdhkar();
//
//         print('✅ GetAdhkar انتهى');
//         print('📿 عدد الأذكار في Bloc: ${result.length}');
//
//         if (result.isNotEmpty) {
//           print('📝 أول ذكر:');
//           print('ID: ${result.first.id}');
//           print('Category: ${result.first.category}');
//           print('Text: ${result.first.text}');
//           print('Count: ${result.first.count}');
//         }
//
//         emit(AdhkarLoaded(result));
//
//         print('✅ تم إرسال AdhkarLoaded');
//       } catch (e, stackTrace) {
//         print('❌ ERROR داخل AdhkarBloc');
//         print('❌ $e');
//         print('📍 $stackTrace');
//
//         emit(AdhkarError(e.toString()));
//       }
//     });
//   }
// }