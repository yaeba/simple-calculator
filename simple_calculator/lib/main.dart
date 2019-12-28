import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter/material.dart';

void main() => runApp(SimpleCalculatorApp());

class SimpleCalculatorApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Calculator',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: SimpleCalculator(title: 'Simple Calculator'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SimpleCalculator extends StatefulWidget {
  final String title;

  SimpleCalculator({Key key, this.title}) : super(key: key);

  @override
  _SimpleCalculatorState createState() => _SimpleCalculatorState();
}

class _SimpleCalculatorState extends State<SimpleCalculator> {
  String expression = "0";
  bool isNegative = false;
  String answer = "0";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: createDisplay(expression),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.black,
              child: createPad(),
            ),
          )
        ],
      ),
    );
  }

  Widget createDisplay(String expr) {
    return Row(
      children: <Widget>[
        Expanded(
          child: AutoSizeText(
            expr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 70,
            ),
            maxLines: 2,
            textAlign: TextAlign.right,
          ),
        )
      ],
    );
  }

  void delExpr() {
    String expr = this.expression;
    int len = expr.length;

    if (expr.substring(len - 1) == "s") {
      expr = expr.substring(0, len - 3);
    } else {
      expr = expr.substring(0, len - 1);
    }

    if (expr.length == 0) {
      expr = "0";
    }
    this.expression = expr;
  }

  void plusMinusExpr() {
    String expr = this.expression;
    if (expr == "0") return;

    if (this.isNegative) {
      this.expression = expr.substring(2);
    } else {
      this.expression = "-(" + expr;
    }
    this.isNegative = !this.isNegative;
    return;
  }

  void evaluateExpr() {
    String expr = this.expression;
    expr = expr.replaceAll(new RegExp('%'), 'x0.01');
    expr = expr.replaceAll(new RegExp('x'), '*');

    try {
      Parser p = new Parser();
      Expression parsed = p.parse(expr);
      ContextModel cm = new ContextModel();
      cm.bindVariable(
          new Variable("Ans"), new Number(double.parse(this.answer)));
      double evaluated = parsed.evaluate(EvaluationType.REAL, cm);

      NumberFormat forInts = new NumberFormat();
      NumberFormat forFractions = new NumberFormat();

      forFractions.maximumFractionDigits = 9;

      format(num n) =>
          n == n.truncate() ? forInts.format(n) : forFractions.format(n);
      this.expression = format(evaluated).replaceAll(new RegExp(','), '');
      this.answer = this.expression;
      this.isNegative = false;
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void updateDisplay(String input) {
    int len = this.expression.length;

    setState(() {
      if (input == "AC") {
        this.expression = "0";
        this.isNegative = false;
      } else if (input == "Del") {
        delExpr();
      } else if (input == "+/-") {
        plusMinusExpr();
      } else if (input == "=") {
        evaluateExpr();
      } else {
        this.expression = this.expression == "0" &&
                (int.tryParse(input) != null || input == "Ans")
            ? input
            : this.expression + input;
      }
    });
  }

  Widget createButton(String text,
      {Color color = Colors.white, Color btnColor = Colors.blueGrey}) {
    return Expanded(
      child: MaterialButton(
        minWidth: double.maxFinite,
        child: AutoSizeText(
          text,
          style: TextStyle(
            color: color,
            fontSize: 30,
          ),
          maxLines: 1,
        ),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        onPressed: () => updateDisplay(text),
        shape: CircleBorder(),
        color: btnColor,
      ),
    );
  }

  Widget createPad() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              createButton('(', color: Colors.lightGreen),
              createButton(')', color: Colors.lightGreen),
              createButton('+/-', color: Colors.lightGreen),
              createButton('^', color: Colors.lightGreen),
              Expanded(child: Container())
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: <Widget>[
              createButton('7'),
              createButton('8'),
              createButton('9'),
              createButton('Del', color: Colors.amber),
              createButton('AC', color: Colors.orange),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: <Widget>[
              createButton('4'),
              createButton('5'),
              createButton('6'),
              createButton('x', color: Colors.lightGreen),
              createButton('+', color: Colors.lightGreen),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: <Widget>[
              createButton('1'),
              createButton('2'),
              createButton('3'),
              createButton('/', color: Colors.lightGreen),
              createButton('-', color: Colors.lightGreen),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: <Widget>[
              createButton('0'),
              createButton('.'),
              createButton('%', color: Colors.lightGreen),
              createButton('Ans', color: Colors.lightBlueAccent),
              createButton('=', btnColor: Colors.green),
            ],
          ),
        ),
      ],
    );
  }
}
