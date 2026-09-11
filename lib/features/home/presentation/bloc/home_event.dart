// import 'package:equatable/equatable.dart';
//
//
//
// abstract class HomeEvent extends Equatable {
//   const HomeEvent();
//
//   @override
//   List<Object?> get props => [];
// }
//
// /// يتم استدعاؤه عند فتح Home
// class LoadHomeLocation extends HomeEvent {
//   const LoadHomeLocation();
// }
//
// /// يتم استدعاؤه بعد الرجوع من LocationPage
// class HomeLocationSelected extends HomeEvent {
//   final dynamic location;
//   final dynamic type;
//
//   const HomeLocationSelected({
//     required this.location,
//     required this.type,
//   });
//
//   @override
//   List<Object?> get props => [
//     location,
//     type,
//   ];
// }