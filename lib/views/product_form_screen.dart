import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class ProductFormScreen extends StatefulWidget {
  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  Widget _buildCategoryField() {
    return TextFormField(
      initialValue: _formData['category'] as String?,
      decoration: const InputDecoration(labelText: 'Categoria'),
      textInputAction: TextInputAction.next,
      focusNode: _categoryFocusNode,
      onSaved: (value) => _formData['category'] = value!,
      validator: (value) {
        bool isEmpty = value!.trim().isEmpty;

        if (isEmpty) {
          return 'Informe uma Categoria válida!';
        }

        return null;
      },
    );
  }
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  final _formData = Map<String, Object>();
  final _discountPercentageFocusNode = FocusNode();
  final _ratingFocusNode = FocusNode();
  final _stockFocusNode = FocusNode();
  final _brandFocusNode = FocusNode();
  final _categoryFocusNode = FocusNode();
  final _thumbnailFocusNode = FocusNode();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_formData.isEmpty) {
      final product = ModalRoute.of(context)!.settings.arguments as Product?;

      if (product != null) {
        _formData['id'] = product.id;
        _formData['title'] = product.title;
        _formData['description'] = product.description;
        _formData['price'] = product.price;
        _formData['discountPercentage'] = product.discountPercentage;
        _formData['rating'] = product.rating;
        _formData['stock'] = product.stock;
        _formData['brand'] = product.brand;
        _formData['category'] = product.category;
        _formData['thumbnail'] = product.thumbnail;
        _formData['imageUrl'] = product.image;

        _imageUrlController.text = _formData['imageUrl'] as String;
      } else {
        _formData['price'] = '';
      }
    }
  }

  void _updateImage() {
    if (isValidImageUrl(_imageUrlController.text)) {
      setState(() {});
    }
  }

  bool isValidImageUrl(String url) {
    final pattern =
        RegExp(r'(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png|jpeg)');

    return pattern.hasMatch(url);
  }

  @override
  void dispose() {
    super.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_updateImage);
    _imageUrlFocusNode.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }

    _form.currentState!.save();

    final product = Product(
      id: _formData['id'] as String? ?? '',
      title: _formData['title'] as String,
      description: _formData['description'] as String,
      price: double.tryParse(_formData['price'] as String) ?? 0.0,
      discountPercentage: _formData['discountPercentage'] != null
          ? double.tryParse(_formData['discountPercentage'] as String) ?? 0.0
          : 0.0,
      rating: _formData['rating'] != null
          ? double.tryParse(_formData['rating'] as String) ?? 0.0
          : 0.0,
      stock: _formData['stock'] != null
          ? int.tryParse(_formData['stock'] as String) ?? 0
          : 0,
      brand: _formData['brand'] as String? ?? '',
      category: _formData['category'] as String? ?? '',
      thumbnail: _formData['thumbnail'] as String? ?? '',
      image: _formData['imageUrl'] as String,
    );

    setState(() {
      _isLoading = true;
    });

    final products = Provider.of<Products>(context, listen: false);
    if (_formData['id'] == null) {
      try {
        await products.addProduct(product);
        Navigator.of(context).pop();
      } catch (error) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Ocorreu um erro!'),
            content: const Text('Ocorreu um erro pra salvar o produto!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      products.updateProduct(product);
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  Widget _buildTitleTextField() {
    return TextFormField(
      initialValue: _formData['title'] as String?,
      decoration: const InputDecoration(labelText: 'Título'),
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(_priceFocusNode);
      },
      onSaved: (value) => _formData['title'] = value!,
      validator: (value) {
        bool isEmpty = value!.trim().isEmpty;
        bool isInvalid = value.trim().length < 3;

        if (isEmpty || isInvalid) {
          return 'Informe um Título válido com no mínimo 3 caracteres!';
        }

        return null;
      },
    );
  }

  Widget _buildPriceTextField() {
    return TextFormField(
      initialValue: _formData['price'].toString(),
      decoration: const InputDecoration(labelText: 'Preço'),
      textInputAction: TextInputAction.next,
      focusNode: _priceFocusNode,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(_descriptionFocusNode);
      },
      onSaved: (value) => _formData['price'] = value!,
      validator: (value) {
        bool isEmpty = value!.trim().isEmpty;
        var newPrice = double.tryParse(value ?? '');
        bool isInvalid = newPrice == null || newPrice <= 0;

        if (isEmpty || isInvalid) {
          return 'Informe um Preço válido!';
        }

        return null;
      },
    );
  }

  Widget _buildDescriptionTextField() {
    return TextFormField(
      initialValue: _formData['description'] as String?,
      decoration: const InputDecoration(labelText: 'Descrição'),
      maxLines: 3,
      keyboardType: TextInputType.multiline,
      focusNode: _descriptionFocusNode,
      onSaved: (value) => _formData['description'] = value!,
      validator: (value) {
        bool isEmpty = value!.trim().isEmpty;
        bool isInvalid = value.trim().length < 10;

        if (isEmpty || isInvalid) {
          return 'Informe uma Descrição válida com no mínimo 10 caracteres!';
        }

        return null;
      },
    );
  }

  Widget _buildImageUrlTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'URL da Imagem'),
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.done,
      focusNode: _imageUrlFocusNode,
      controller: _imageUrlController,
      onFieldSubmitted: (_) {
        _saveForm();
      },
      onSaved: (value) => _formData['imageUrl'] = value!,
      validator: (value) {
        bool isEmpty = value!.trim().isEmpty;
        bool isInvalid = !isValidImageUrl(value);

        if (isEmpty || isInvalid) {
          return 'Informe uma URL válida!';
        }

        return null;
      },
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 100,
      width: 100,
      margin: const EdgeInsets.only(
        top: 8,
        left: 10,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: _imageUrlController.text.isEmpty
          ? const Text('Informe a URL')
          : FittedBox(
              child: Image.network(
                _imageUrlController.text,
                fit: BoxFit.cover,
              ),
            ),
    );
  }

  Widget _buildDiscountPercentageField() {
    final initialValue = _formData['discountPercentage'] != null
        ? _formData['discountPercentage'].toString()
        : '';
    return TextFormField(
      initialValue: initialValue,
      decoration: const InputDecoration(labelText: 'Desconto (%)'),
      textInputAction: TextInputAction.next,
      focusNode: _discountPercentageFocusNode,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(_ratingFocusNode);
      },
      onSaved: (value) => _formData['discountPercentage'] = value!,
      validator: (value) {
        bool isEmpty = value!.trim().isEmpty;
        var newDiscountPercentage = double.tryParse(value ?? '');
        bool isInvalid =
            newDiscountPercentage == null || newDiscountPercentage < 0;

        if (isEmpty || isInvalid) {
          return 'Informe um Desconto válido!';
        }

        return null;
      },
    );
  }

  Widget _buildRatingField() {
    final initialValue = _formData['rating'] != null
        ? _formData['rating'].toString()
        : '';
    return TextFormField(
      initialValue: initialValue,
      decoration: const InputDecoration(labelText: 'Avaliação'),
      textInputAction: TextInputAction.next,
      focusNode: _ratingFocusNode,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(_stockFocusNode);
      },
      onSaved: (value) => _formData['rating'] = value!,
      validator: (value) {
        bool isEmpty = value!.trim().isEmpty;
        var newRating = double.tryParse(value ?? '');
        bool isInvalid = newRating == null || newRating < 0 || newRating > 5;

        if (isEmpty || isInvalid) {
          return 'Informe uma Avaliação válida!';
        }

        return null;
      },
    );
  }

  Widget _buildStockField() {
    final initialValue =
        _formData['stock'] != null ? _formData['stock'].toString() : '';
    return TextFormField(
      initialValue: initialValue,
      decoration: const InputDecoration(labelText: 'Estoque'),
      textInputAction: TextInputAction.next,
      focusNode: _stockFocusNode,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(_brandFocusNode);
      },
      onSaved: (value) => _formData['stock'] = value!,
      validator: (value) {
        bool isEmpty = value!.trim().isEmpty;
        var newStock = double.tryParse(value ?? '');
        bool isInvalid = newStock == null || newStock < 0;

        if (isEmpty || isInvalid) {
          return 'Informe um Estoque válido!';
        }

        return null;
      },
    );
  }

  Widget _buildBrandField() {
    return TextFormField(
      initialValue: _formData['brand'] as String?,
      decoration: const InputDecoration(labelText: 'Marca'),
      textInputAction: TextInputAction.next,
      focusNode: _brandFocusNode,
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(_categoryFocusNode);
      },
      onSaved: (value) => _formData['brand'] = value!,
      validator: (value) {
        bool isEmpty = value!.trim().isEmpty;

        if (isEmpty) {
          return 'Informe uma Marca válida!';
        }

        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulário Produto'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    _buildTitleTextField(),
                    _buildPriceTextField(),
                    _buildDescriptionTextField(),
                    _buildDiscountPercentageField(),
                    _buildRatingField(),
                    _buildStockField(),
                    _buildBrandField(),
                    _buildCategoryField(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(child: _buildImageUrlTextField()),
                        _buildImagePreview(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
