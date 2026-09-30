import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

class SetupBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    log(change.toString());
    super.onChange(bloc, change);
  }
}
