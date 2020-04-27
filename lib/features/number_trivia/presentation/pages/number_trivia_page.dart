import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trivia_app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:trivia_app/features/number_trivia/presentation/widgets/widgets.dart';
import 'package:trivia_app/injection_container.dart';

class NumberTriviaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Trivia'),
      ),
      body: SingleChildScrollView(child: buildBody(context)),
    );
  }

  BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NumberTriviaBloc>(),
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            SizedBox(height: 8),
            BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
              builder: (context, state) {
                if (state is Empty) {
                  return MessageDisplay(message: 'Start searching!');
                } else if (state is Loading) {
                  return LoadingWidget();
                } else if (state is Loaded) {
                  return NumberTriviaDisplay(numberTrivia: state.numberTrivia);
                } else if (state is Error) {
                  return MessageDisplay(message: state.message);
                }
              },
            ),
            SizedBox(height: 16),
            NumberTriviaControlsWidget()
          ],
        ),
      ),
    );
  }
}
