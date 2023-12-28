import 'package:flutter/material.dart';

class CreatePackage extends StatefulWidget {
  final Map? index;
  final List<Map<String, dynamic>> productList;

  CreatePackage({this.index, required this.productList});

  @override
  _CreatePackageState createState() => _CreatePackageState();
}

class _CreatePackageState extends State<CreatePackage> {
  @override
  void initState() {
    if(widget.index != null) {
      activatee = widget.index!['status'] ?? false;
      edit = true;
      idctlr.text = widget.index!['id'] ?? "";
      titlectlr.text = widget.index!['title'] ?? "";
      descctlr.text = widget.index!['description'] ?? "";
      if (mounted) setState(() {});
    }
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> data = {};

  TextEditingController idctlr = TextEditingController();

  TextEditingController titlectlr = TextEditingController();

  TextEditingController descctlr = TextEditingController();

  bool edit = false;
  bool activatee = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                edit ? "Edit subscription" : "Add new subscription",
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 25,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: Icon(
                Icons.cancel,
                color: Color(0xfff0f0f0),
              ),
              onPressed: () => Navigator.pop(context, null),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                edit ? "Save Changes" : "SAVE",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  data['status'] = activatee;
                  Navigator.pop(context, data);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 20, right: 100),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: ListTile(
                dense: true,
                leading: Checkbox(
                  value: activatee,
                  tristate: true,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (val) {
                    setState(
                      () {
                        activatee = !activatee;
                        // widget.index["status"] = !widget.index["status"];
                      },
                    );
                  },
                ),
                title: Text("Activate"),
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 90),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: titlectlr,
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return 'Please enter title';
                      }
                      return null;
                    },
                    cursorColor: Theme.of(context).primaryColor,
                    decoration: InputDecoration(
                      helperText: "this is how it will appear in app",
                      labelText: "Title",
                      hintText: "Title",
                    ),
                    onSaved: (value) {
                      data['title'] = value;
                    },
                  ),
                  TextFormField(
                    controller: idctlr,
                    readOnly: edit,
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return 'Please enter id';
                      } else if (data['id'] != null && widget.productList.any((element) => element['id'] == value)) {
                        return 'id already exist ';
                      }
                      return null;
                    },
                    cursorColor: Theme.of(context).primaryColor,
                    decoration: InputDecoration(
                      helperText: "it should match with play console product id",
                      labelText: "Product id",
                      hintText: "Product id",
                    ),
                    onChanged: (value) {
                      data['id'] = value;
                    },
                  ),
                  TextFormField(
                    controller: descctlr,
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                    minLines: 2,
                    autofocus: false,
                    cursorColor: Theme.of(context).primaryColor,
                    maxLines: 5,
                    decoration: InputDecoration(
                      helperText: "this is how it will appear in app",
                      labelText: "Description",
                      hintText: "Description",
                    ),
                    onSaved: (value) {
                      data['description'] = value;
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
