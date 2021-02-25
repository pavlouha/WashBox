import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:washbox/other/colors.dart';
import 'package:washbox/other/borders.dart';
import 'package:hexcolor/hexcolor.dart';

import 'package:washbox/views/widgets/login_and_registration.dart';
import 'package:washbox/pages/registration_page.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:washbox/logic/blocs/auth/login_form_bloc.dart';

import 'package:formz/formz.dart';

class LoginView extends StatefulWidget {
  LoginView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginView> {

  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  ///Кнопка входа
  Widget _submitButton() {
    return BlocBuilder<LoginFormBloc, LoginFormState>(
    buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) {
      return TextButton(
        onPressed: state.status.isValidated ? () => context.read<LoginFormBloc>().add(LoginFormSubmitted()) : null,
    child: Container(
    width: MediaQuery.of(context).size.width,
    padding: EdgeInsets.all(15),
    alignment: Alignment.center,
    decoration: BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    color: HexColor('#16850f'),
    ),
    child: Text(
    'Войти',
    style: TextStyle(fontSize: 20, color: Colors.white),
    ),
    ),);
    });
  }

  ///Кнопка регистрации
  Widget _registerButton() {
    return  TextButton(
      onPressed: () =>
       //TODO перевести на блок (если возможно)
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => RegistrationPage())),
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(bottom: 15),
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: buttonColor,
        ),
        child: Text(
          'Регистрация',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),);
  }

  ///Виджет-колонка
  ///Содержит поля ввода
  Widget _loginPasswordWidget() {
    return Column(
      children: <Widget>[
        numberWidget("Телефон", _phoneFocusNode),
        passwordWidget("Пароль", _passwordFocusNode),
      ],
    );
  }

  ///Построение страницы. Приложение обёрнуто в даблтап для предотвращения случайного выхода
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: DoubleBackToCloseApp(
        snackBar: SnackBar(backgroundColor: backgroundColor,
            content: Container(margin: EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              height: 50,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                color: Colors.white,
              ),
              child: Text('Ещё раз нажмите "назад" для выхода', style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),),
            )
        ),
        child: Container(
          height: height,
          color: backgroundColor,
          child: Stack(
            children: <Widget>[
    BlocListener<LoginFormBloc, LoginFormState>(
    listener: (context, state) {
      //TODO потом
      if (state.status.isSubmissionInProgress) {
        Scaffold.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Работает!')),
          );
      }},
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: height * .2),
              SizedBox(height: 30),
              // title("Вход", context),
              Image(image: AssetImage('assets/logo.png'), height: 150),
              SizedBox(height: 30),
              _loginPasswordWidget(),
              SizedBox(height: 30),
              _submitButton(),
              _registerButton(),
            ],
          ),
        ),
      ),
    ),
            ],
          ),
        ),
      ),
    );
  }

  ///Убираем текстовые ноды
  @override
  void dispose() {
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
      if (!_phoneFocusNode.hasFocus) {
        context.read<LoginFormBloc>().add(PhoneUnfocused());
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      }
    });
    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        context.read<LoginFormBloc>().add(PasswordUnfocused());
      }
    });
  }
}

/// Виджет, содержащий местечко для ввода пароля. Нажатие на глаз переключает
/// видимость пароля (звёздочки)
Widget passwordWidget(String title, FocusNode focusNode) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        BlocBuilder<LoginFormBloc, LoginFormState>(
          builder: (context, state) {
            return TextFormField(
              initialValue: state.password.value,
              textInputAction: TextInputAction.done,
              obscureText: state.hidden,
              focusNode: focusNode,
              decoration: InputDecoration(
                  errorText: state.password.invalid ? '8 символов, минимум 1 цифра' : null,
                  suffixIcon: IconButton(
                    icon: state.hidden == true ? Icon(Icons.remove_red_eye_outlined, color: Colors.black) :
                    Icon(Icons.remove_red_eye, color: Colors.black),
                    onPressed: () {
                      context.read<LoginFormBloc>().add(VisibilityChanged(hidden: state.hidden));
                    },
                  ),
                  hintText: title,
                  enabledBorder: inputBorder(),
                  focusedBorder: inputBorder(),
                  fillColor: inputTextColor,
                  filled: true),
              onChanged: (value) {
                context.read<LoginFormBloc>().add(PasswordChanged(password: value));
              },);
          },
        ),
      ],
    ),
  );
}