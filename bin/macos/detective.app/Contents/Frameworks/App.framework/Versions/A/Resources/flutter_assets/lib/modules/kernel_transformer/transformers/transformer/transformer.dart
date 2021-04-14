
import 'package:args/args.dart';
import 'package:frontend_server/frontend_server.dart' as frontend
    show
    FrontendCompiler,
    CompilerInterface,
    listenAndCompile,
    argParser,
    usage,
    ProgramTransformer;
import 'package:kernel/ast.dart';
import 'test_transformer.dart';
import 'package:path/path.dart' as path;
import 'package:vm/incremental_compiler.dart';
import 'package:vm/target/flutter.dart';

/// Replaces [Object.toString] overrides with calls to super for the specified
/// [packageUris].
class DetectiveTransformer extends FlutterProgramTransformer {
    /// The [packageUris] parameter must not be null, but may be empty.
    DetectiveTransformer();

    @override
    void transform(Component component) {
        return ActualTransformer().transform(component);

    }
}