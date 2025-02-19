import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = "0";
  String _input = "";
  double _num1 = 0;
  double _num2 = 0;
  String _operator = "";

  void _buttonPressed(String value) {
    setState(() {
      if (value == "C") {
        _output = "0";
        _input = "";
        _num1 = 0;
        _num2 = 0;
        _operator = "";
      } else if (value == "=") {
        _num2 = double.parse(_input);

        switch (_operator) {
          case "+":
            _output = (_num1 + _num2).toString();
            break;
          case "-":
            _output = (_num1 - _num2).toString();
            break;
          case "x":
            _output = (_num1 * _num2).toString();
            break;
          case "/":
            _output = (_num2 != 0) ? (_num1 / _num2).toString() : "Error";
            break;
        }

        _input = _output;
        _operator = "";
      } else if (value == "+" || value == "-" || value == "x" || value == "/") {
        _num1 = double.parse(_input);
        _operator = value;
        _input = "";
      } else {
        if (_input == "0") {
          _input = value;
        } else {
          _input += value;
        }
      }
      _output = _input;
    });
  }

  Widget _buildButton(String text, {Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () => _buttonPressed(text),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(20),
            shape: const CircleBorder(),
            backgroundColor: color ?? Colors.white24,
            foregroundColor: Colors.white,
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: Text(
                _output,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          Column(
            children: [
              Row(children: [_buildButton("7"), _buildButton("8"), _buildButton("9"), _buildButton("x", color: Colors.grey)]),
              Row(children: [_buildButton("4"), _buildButton("5"), _buildButton("6"), _buildButton("/", color: Colors.grey)]),
              Row(children: [_buildButton("1"), _buildButton("2"), _buildButton("3"), _buildButton("+", color: Colors.grey)]),
              Row(children: [
                _buildButton("=", color: Colors.orange),
                _buildButton("0"),
                _buildButton("C", color: Colors.grey),
                _buildButton("-", color: Colors.grey),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
