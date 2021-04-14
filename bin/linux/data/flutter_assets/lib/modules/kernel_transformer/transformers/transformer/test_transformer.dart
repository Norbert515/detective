import 'package:kernel/ast.dart';
import 'package:kernel/src/printer.dart';
import 'package:kernel/library_index.dart';

class ActualTransformer {
  void transform(Component component) {
    var libraryIndex = LibraryIndex.coreLibraries(component);
    component.visitChildren(StringChanger(libraryIndex.getMember("dart:core", '::', 'print')));

  }
}

void log(String it) {
  print('transformer: $it');
}

class StringChanger extends RecursiveVisitor {

  StringChanger(this.printProcedure);

  final Procedure printProcedure;


  @override
  visitStringLiteral(StringLiteral node) {
    if(node.value == 'Feedback') {
      node.value = 'Hahahah no feedback122';
    }
    return super.visitStringLiteral(node);
  }

  visitProcedureReference(Procedure node) {

    if(node.name.text == 'doIt') {
      log('Found procedure with name doIt42');
      log('Bloc type ${node.function.body.runtimeType}');
      if(node.function.body is Block) {
        Block block = node.function.body;
        block.statements.insert(0, ExpressionStatement(StaticInvocation(
          printProcedure, Arguments([StringLiteral('Printed from kerneeeel42')]),
        )));
      }
    }

    return super.visitProcedureReference(node);
  }

  @override
  visitConstructorInvocation(ConstructorInvocation node) {
    var i = node.targetReference.asConstructor;

    if(!i.isConst) {
      node.isConst = false;
    }
    return super.visitConstructorInvocation(node);
  }

  @override
  visitListLiteral(ListLiteral node) {
    node.isConst = false;
    return super.visitListLiteral(node);
  }

  @override
  visitMapLiteral(MapLiteral node) {
    node.isConst = false;
    return super.visitMapLiteral(node);
  }
  void visitClassReference(Class node) {
    node.ensureLoaded();


    if(/*node.name == 'C' &&*/ !node.isEnum) {

      if(node.hasConstConstructor) {
        // Remove all const from constructors, as fields can not be mutable for
        // classes with const constructors

        for(var constructor in node.constructors) {
          constructor.isConst = false;
          node.dirty = true;
        }
      }

      for(var field in node.fields) {


        if(field.isFinal && !field.isConst) {
          var finalField = Field.mutable(field.name,
            initializer: field.initializer,
            type: field.type,
            fileUri: field.fileUri,
            isCovariant: field.isCovariant,
            isFinal: false,
            isLate: field.isLate,
            isStatic: field.isStatic,
            transformerFlags: field.transformerFlags,
            getterReference: field.getterReference,
            // With the introduction of the late keyword, final variables can
            // have a setter, use that in that case
            setterReference: field.setterReference?? Reference(),
          );

          field.replaceWith(finalField);
          node.dirty = true;
        }
      }


    }
  }




}