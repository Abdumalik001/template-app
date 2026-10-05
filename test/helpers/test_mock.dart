import 'package:cactus_hr/features/features.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  AuthRepository,
  AuthRemoteDatasource,
  UsersRepository,
  UsersRemoteDatasource,
])
@GenerateNiceMocks([MockSpec<BuildContext>()])
void main() {}
