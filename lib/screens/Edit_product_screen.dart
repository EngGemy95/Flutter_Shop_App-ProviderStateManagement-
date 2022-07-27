import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({Key? key}) : super(key: key);

  static const String routeName = 'edit-product';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  Product _editingProduct = Product(
    id: '',
    title: '',
    imageUrl: '',
    description: '',
    price: 0,
  );

  //final _imageUrlFocusNode = FocusNode();

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments as String?;
      if (productId != null) {
        _editingProduct = Provider.of<ProductsProvider>(context, listen: false)
            .getProductById(productId);

        _imageUrlController.text = _editingProduct.imageUrl;
      }
    }
    _isInit = false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _descriptionFocusNode.dispose();
    _priceFocusNode.dispose();
    _imageUrlController.dispose();
    // _imageUrlFocusNode.dispose();
    //  _imageUrlFocusNode.removeListener(_updateImageUrl);
  }

  // void _updateImageUrl(){
  //   if(!_imageUrlFocusNode.hasFocus){
  //     setState(() {
  //     });
  //   }
  // }

  void _saveForm() async {
    final isVaild = _form.currentState!.validate();
    if (isVaild) {
      _form.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      if (_editingProduct.id == '') {
        try {
          await Provider.of<ProductsProvider>(context, listen: false)
              .addProduct(_editingProduct);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('${_editingProduct.title} is added successfully')));
        } catch (error) {
          await showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: Text('An Error Occurred!'),
                  content: Text('Something went error.'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text('Okey')),
                  ],
                );
              });
        }
        // finally {
        //   Navigator.of(context).pop();
        // }
      } else {
        await Provider.of<ProductsProvider>(context, listen: false)
            .updateProduct(_editingProduct.id, _editingProduct);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${_editingProduct.title} is Updated successfully')));
      }
      // setState(() {
      _isLoading = false;
      // });
      print(_isLoading);
      Navigator.of(context).pop();
      // print(editingProduct.title);
      // print(editingProduct.description);
      // print(editingProduct.price);
      // print(editingProduct.imageUrl);

    }
  }

  String? validateImageUrl(String imageUrl) {
    //   var urlPattern =
    //     r"(https?|ftp)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
    // var result = RegExp(urlPattern, caseSensitive: false)
    //     .firstMatch('https://www.google.com');

    if (imageUrl.isEmpty) {
      return 'Enter an image URL !';
    }
    if (!imageUrl.startsWith('http') && !imageUrl.startsWith('https')) {
      return 'Enter a vaild URL !';
    }
    if (!imageUrl.endsWith('.png') &&
        !imageUrl.endsWith('.jpg') &&
        !imageUrl.endsWith('.jpeg')) {
      return 'Enter a vaild image URL !';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
              onPressed: () {
                _saveForm();
              },
              icon: Icon(Icons.save)),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _form,
                  //we use here listview as the input not many and the screen is portrait
                  //but if we use multi input or the screen size is small
                  //we use instead
                  // Form(
                  //     child: SingleChildScrollView(
                  //         child: Column(
                  //             children: [ ... ],
                  //         ),
                  //     ),
                  // ),
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _editingProduct.title,
                        decoration: InputDecoration(
                          labelText: 'Title',
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Title!';
                          }
                        },
                        onSaved: (newValue) {
                          _editingProduct = Product(
                            id: _editingProduct.id,
                            title: newValue ?? '',
                            imageUrl: _editingProduct.imageUrl,
                            description: _editingProduct.description,
                            price: _editingProduct.price,
                            isFavorite: _editingProduct.isFavorite,
                          );
                        },
                      ),
                      TextFormField(
                        initialValue: _editingProduct.price.toString(),
                        decoration: InputDecoration(
                          labelText: 'Price',
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Price!';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Enter a vaild number!';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Enter a number greater than zero!';
                          }
                          //if value is vaild
                          return null;
                        },
                        onSaved: (newValue) {
                          _editingProduct = Product(
                            id: _editingProduct.id,
                            title: _editingProduct.title,
                            imageUrl: _editingProduct.imageUrl,
                            description: _editingProduct.description,
                            price: double.parse(newValue ?? '0'),
                            isFavorite: _editingProduct.isFavorite,
                          );
                        },
                      ),
                      TextFormField(
                        initialValue: _editingProduct.description,
                        decoration: InputDecoration(
                          labelText: 'Description',
                        ),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        onSaved: (newValue) {
                          _editingProduct = Product(
                            id: _editingProduct.id,
                            title: _editingProduct.title,
                            imageUrl: _editingProduct.imageUrl,
                            description: newValue ?? '',
                            price: _editingProduct.price,
                            isFavorite: _editingProduct.isFavorite,
                          );
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Descriotion!';
                          }
                          if (value.length < 10) {
                            return 'Should be at least 10 character long!';
                          }
                          return null;
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            margin:
                                EdgeInsetsDirectional.fromSTEB(0, 10, 10, 0),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? Text(
                                    'Enter image url',
                                    //textAlign: TextAlign.center,
                                  )
                                : Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Image Url'),
                              keyboardType: TextInputType.url,
                              controller: _imageUrlController,
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                              validator: (value) {
                                return validateImageUrl(value!);
                              },
                              onSaved: (newValue) {
                                _editingProduct = Product(
                                  id: _editingProduct.id,
                                  title: _editingProduct.title,
                                  imageUrl: newValue ?? '',
                                  description: _editingProduct.description,
                                  price: _editingProduct.price,
                                  isFavorite: _editingProduct.isFavorite,
                                );
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                                onPressed: () {
                                  if (validateImageUrl(
                                          _imageUrlController.text) ==
                                      null) {
                                    setState(() {});
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    // Then show a snackbar.
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                '${validateImageUrl(_imageUrlController.text)}')));
                                  }
                                },
                                child: Text(
                                  'Check Image',
                                  style: TextStyle(color: Colors.white),
                                )),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
    );
  }
}
