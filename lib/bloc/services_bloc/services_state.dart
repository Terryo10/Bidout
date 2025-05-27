part of 'services_bloc.dart';

sealed class ServicesState extends Equatable {
  const ServicesState();
  
  @override
  List<Object> get props => [];
}

final class ServicesInitial extends ServicesState {}
