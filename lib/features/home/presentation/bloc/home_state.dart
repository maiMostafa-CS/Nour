// import 'package:equatable/equatable.dart';
//
//
//
// abstract class HomeState extends Equatable {
//   const HomeState();
//
//   @override
//   List<Object?> get props => [];
// }
//
// class HomeInitial extends HomeState {
//   const HomeInitial();
// }
//
// class HomeLocationLoading extends HomeState {
//   const HomeLocationLoading();
// }
//
// class HomeLocationLoaded extends HomeState {
//   final double latitude;
//   final double longitude;
//   final String cityName;
//
//   const HomeLocationLoaded({
//     required this.latitude,
//     required this.longitude,
//     required this.cityName,
//   });
//
//   @override
//   List<Object?> get props => [
//     latitude,
//     longitude,
//     cityName,
//   ];
// }
//
// class HomeLocationError extends HomeState {
//   final String message;
//
//   const HomeLocationError(this.message);
//
//   @override
//   List<Object?> get props => [message];
// }