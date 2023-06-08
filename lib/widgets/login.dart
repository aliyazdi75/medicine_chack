import 'package:daroo_check/models/index.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Login extends StatelessWidget {
  Login({super.key, required this.userBox});

  final Box<User> userBox;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final ageFocusNode = FocusNode();

  int? _persianNumberConverter(String num) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    for (int i = 0; i < english.length; i++) {
      num = num.replaceAll(persian[i], english[i]);
    }
    return int.tryParse(num);
  }

  void _submit() {
    if (formKey.currentState!.validate()) {
      userBox.put(
        userKey,
        User(
          name: nameController.text,
          age: _persianNumberConverter(ageController.text)!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'خوش آمدید',
            ),
            TextFormField(
              controller: nameController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              onEditingComplete: () => ageFocusNode.requestFocus(),
              keyboardType: TextInputType.name,
              validator: (name) =>
                  name!.isEmpty ? 'لطفا اسمتان را وارد کنید' : null,
              decoration: const InputDecoration(
                labelText: 'اسم',
              ),
            ),
            TextFormField(
              controller: ageController,
              focusNode: ageFocusNode,
              textInputAction: TextInputAction.go,
              onEditingComplete: _submit,
              keyboardType: TextInputType.number,
              validator: (age) {
                if (age!.isEmpty) {
                  return 'لطفا سن را وارد کنید';
                }
                final ageInt = _persianNumberConverter(age);
                if (ageInt == null || ageInt < 1 || ageInt > 100) {
                  return 'لطفا سن را عددی بین صفر تا صد وارد کنید';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'سن',
              ),
            ),
            ElevatedButton(
              onPressed: _submit,
              child: const Center(
                child: Text('ورود'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
