import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:keto/shared/app_color.dart';
import 'package:keto/viewmodels/takenote_model.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';

class TakeNote extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Take note"),
        backgroundColor: primary,
        leading: IconButton(
          icon: Icon(Icons.close),
          padding: EdgeInsets.all(4.0),
          iconSize: 34.0,
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: ChangeNotifierProvider<TakeNoteModel>(
        builder: (_) => TakeNoteModel(),
        child: TakeNodeStateFulWidget(),
      ),
    );
  }
}


class TakeNodeStateFulWidget extends StatefulWidget {
  TakeNodeStateFulWidget({Key key}) : super(key: key);

  @override
  _TakeNodeState createState() => _TakeNodeState();
}

class _TakeNodeState extends State<TakeNodeStateFulWidget> {

  final txtController = TextEditingController();
  final amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    txtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = TakeNoteModel.of(context);

    return SingleChildScrollView(
        child: new Container(
          margin: EdgeInsets.only(top: 15.0),
          padding: EdgeInsets.all(15.0),
          child: new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: new StreamBuilder<QuerySnapshot>(
                      stream: model.syncCateList(),
                      builder: (context, snapshot){

                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Center(child: CircularProgressIndicator());

                          default:
                            List<DropdownMenuItem> options = [];
                            var cates = new Map();

                            for (int i=0; i<snapshot.data.documents.length; i++) {
                              DocumentSnapshot docs = snapshot.data.documents[i];

                              cates.addAll({
                                "${docs["cateId"]}" : docs["cateName"]
                              });

                              options.add(DropdownMenuItem<String>(
                                child: Text(docs["cateName"]),
                                value: "${docs["cateId"]}",
                              ));
                            }

                            DocumentSnapshot docs = snapshot.data.documents[0];
                            if (model.getCurrentCate == null) {
                              model.currentCate = docs["cateId"].toString();
                              model.currentCateLabel = docs["cateName"].toString();
                            }

                            return DropdownButton(
                              iconEnabledColor: primary,
                              isExpanded: true,
                              value: model.getCurrentCate,
                              items: options,
                              onChanged: (newItem) => {
                                model.changedCateDropDownItem(newItem, cates[newItem])
                              },
                            );
                        }
                      }
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 20,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child:  DropdownButton(
                    iconEnabledColor: primary,
                    isExpanded: true,
                    value: model.getCurrentType,
                    items: getDropDownMenuItems(model.getTypes),
                    onChanged: model.changedTypeDropDownItem,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 20,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: new InputDecoration(
                      labelText: "Amount",
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(7.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 40,
                ),

                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: TextFormField(
                    controller: txtController,
                    decoration: new InputDecoration(
                      labelText: "Description",
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(7.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 40,
                ),
                RaisedButton(
                  onPressed: () {
                    model.description = txtController.text;
                    model.amount = amountController.text;

                    model.validateAndSubmit();

                    if (model.getErrorMsg != null) {
                      Scaffold.of(context).showSnackBar(new SnackBar(
                        duration: const Duration(milliseconds: 1000),
                        content: new Text(model.getErrorMsg),
                        backgroundColor: Colors.red,
                      ));
                    } else {
                      txtController.clear();
                      amountController.clear();

                      Scaffold.of(context).showSnackBar(new SnackBar(
                        content: new Text("Save sucessfully"),
                        backgroundColor: primary,
                      ));
                    }
                  },
                  color: primary,
                  shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(7.0)),
                  child: SizedBox(
                    width: 250,
                    height: 50,
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(fontSize: 17, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 12,
                ),
                model.isSubmitingData
                ? ScalingText('...', end: 2.0,)
                : Text(""),
              ],
            ),
          ),
        ),
    );
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems(List<String> data) {
    List<DropdownMenuItem<String>> items = new List();
    for (String s in data) {
      items.add(new DropdownMenuItem(
          value: s,
          child: new Text(s)
      ));
    }
    return items;
  }


}
