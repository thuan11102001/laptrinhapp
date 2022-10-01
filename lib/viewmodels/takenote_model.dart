import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class TakeNoteModel extends ChangeNotifier {
  static List<String>  _types = ["Outcome", "Income"];

  String _description;
  String _currentCate;
  String _currentLabelCate;
  String _errorMsg;
  String _amount;
  String _currentType = _types[0];
  bool _isSubmitingData = false;

  String get getCurrentCate => _currentCate;
  String get getCurrentType => _currentType;
  String get getDescription => _description;
  String get getErrorMsg => _errorMsg;
  bool get isSubmitingData => _isSubmitingData;

  List<String> get getTypes => _types;

  static TakeNoteModel of(BuildContext context) {
    return Provider.of<TakeNoteModel>(context);
  }

  Stream<QuerySnapshot> syncCateList() {
    return Firestore.instance.collection('cate').snapshots();
  }

  void changedCateDropDownItem(String itemKeySelected, String itemLabelSelected) {
    _currentCate = itemKeySelected;
    _currentLabelCate = itemLabelSelected;

    print(itemLabelSelected);

    notifyListeners();
  }

  void changedTypeDropDownItem(String itemSelected) {
    _currentType = itemSelected;
    notifyListeners();
  }

  set currentCate(String newItem) {
    _currentCate = newItem;
  }

  set currentCateLabel(String newItem) {
    _currentLabelCate = newItem;
  }

  set description(String newItem) {
    _description = newItem;
  }

  String get amount => _amount;

  set amount(String value) {
    _amount = value;
  }

  void validateAndSubmit() {
    _errorMsg = null;

    if (_description == null || _currentCate == null || _currentType == null) {
      _errorMsg = "Please fill in all fields";
      return;
    }

    var amountNumber = double.tryParse(_amount) ?? 0;
    print("fsdfsdf");
    if (amountNumber == 0) {
      _errorMsg = "Amount is missing";
      return;
    }

    if (_description.length < 6) {
      _errorMsg = "Description too short";
      return;
    }

    save();
  }

  void save() {
    print("add data to firestore");
    _isSubmitingData = true;
    notifyListeners();

    Firestore.instance
    .collection('transactions')
    .add({
      "cateId": _currentCate,
      "cateName": _currentLabelCate,
      "type": _currentType, // income or outcome
      "icon": "assets/images/shopping_bag.png",
      "amount": double.parse(_amount),
      "des": _description,
      "timestamp": FieldValue.serverTimestamp(),
    })
    .then((result) => {
      _isSubmitingData = false,
      notifyListeners()
    })
    .catchError((err) => {
      _errorMsg = "Internal error",
      _isSubmitingData = false,
      notifyListeners()
    });
  }
}