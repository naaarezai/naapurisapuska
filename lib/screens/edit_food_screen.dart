import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../models/food_item.dart';
import '../services/database_service.dart';

class EditFoodScreen extends StatefulWidget {
  final FoodItem foodItem;

  const EditFoodScreen({
    super.key,
    required this.foodItem,
  });

  @override
  State<EditFoodScreen> createState() => _EditFoodScreenState();
}

class _EditFoodScreenState extends State<EditFoodScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage; // Uusi kuva (jos valitaan)
  String? _currentImageUrl; // Nykyinen kuvan URL
  FoodCategory _selectedCategory = FoodCategory.muut;
  bool _isLoading = false;
  double _uploadProgress = 0.0;
  String _loadingMessage = 'Päivitetään ilmoitusta...';
  final DatabaseService _databaseService = DatabaseService();
  bool _isFree = true;

  @override
  void initState() {
    super.initState();
    // Täytä kentät olemassa olevilla tiedoilla
    _titleController.text = widget.foodItem.title;
    _descController.text = widget.foodItem.description;
    _selectedCategory = widget.foodItem.category;
    _currentImageUrl = widget.foodItem.imageUrl;
    _isFree = widget.foodItem.price == null;
    if (widget.foodItem.price != null) {
      _priceController.text = widget.foodItem.price!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Funktio kuvan valitsemiseen (kamera tai galleria)
  Future<void> _pickImage() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ota kuva'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Valitse galleriasta'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _currentImageUrl = null; // Piilota vanha kuva kun uusi on valittu
      });
    }
  }

  // Päivitä ilmoitus
  Future<void> _updateFoodItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parsii hinnan
      double? price;
      if (!_isFree && _priceController.text.trim().isNotEmpty) {
        try {
          price = double.parse(_priceController.text.trim().replaceAll(',', '.'));
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Virheellinen hinta. Käytä esim. 5.00 tai 5,00'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Luo päivitetty FoodItem-olio
      final updatedItem = FoodItem(
        id: widget.foodItem.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        imageUrl: widget.foodItem.imageUrl, // Säilytetään vanha URL, päivitetään jos uusi kuva
        latitude: widget.foodItem.latitude,
        longitude: widget.foodItem.longitude,
        timestamp: widget.foodItem.timestamp, // Säilytetään alkuperäinen aikaleima
        category: _selectedCategory,
        userId: widget.foodItem.userId,
        userName: widget.foodItem.userName,
        userProfileImageUrl: widget.foodItem.userProfileImageUrl,
        price: price,
        isReserved: widget.foodItem.isReserved,
        reservedByUserId: widget.foodItem.reservedByUserId,
      );

      // Päivitä Firebaseen
      await _databaseService.updateFoodItem(
        updatedItem,
        newImageFile: _selectedImage, // Jos uusi kuva on valittu, se ladataan
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _uploadProgress = progress;
              if (_selectedImage != null) {
                if (progress < 0.5) {
                  _loadingMessage = 'Optimoidaan ja ladataan kuvaa...';
                } else if (progress < 0.9) {
                  _loadingMessage = 'Päivitetään tietoja...';
                } else {
                  _loadingMessage = 'Viimeistellään...';
                }
              } else {
                _loadingMessage = 'Päivitetään tietoja...';
              }
            });
          }
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ilmoitus päivitetty onnistuneesti!',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Virhe: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _uploadProgress = 0.0;
          _loadingMessage = 'Päivitetään ilmoitusta...';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muokkaa ilmoitusta'),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _uploadProgress > 0 ? _uploadProgress : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _loadingMessage,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (_uploadProgress > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${(_uploadProgress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Otsikko
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Mitä ruokaa?',
                          hintText: 'Esim. Leipää, hedelmiä, vihanneksia...',
                          prefixIcon: Icon(Icons.fastfood),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Anna otsikko';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Kuvaus
                      TextFormField(
                        controller: _descController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Lisätiedot',
                          hintText: 'Määrä, päiväys, erityisohjeet...',
                          prefixIcon: Icon(Icons.description),
                        ),
                        textInputAction: TextInputAction.newline,
                      ),
                      const SizedBox(height: 20),
                      
                      // Kategoria
                      DropdownButtonFormField<FoodCategory>(
                        value: _selectedCategory,
                        key: ValueKey(_selectedCategory),
                        decoration: const InputDecoration(
                          labelText: 'Kategoria',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: FoodCategory.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Hinta
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.euro, color: Color(0xFFFF8F00)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Hinta',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile<bool>(
                                      title: const Text('Ilmainen'),
                                      value: true,
                                      groupValue: _isFree,
                                      onChanged: (value) {
                                        setState(() {
                                          _isFree = value!;
                                          if (_isFree) {
                                            _priceController.clear();
                                          }
                                        });
                                      },
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile<bool>(
                                      title: const Text('Maksullinen'),
                                      value: false,
                                      groupValue: _isFree,
                                      onChanged: (value) {
                                        setState(() {
                                          _isFree = value!;
                                        });
                                      },
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ],
                              ),
                              if (!_isFree) ...[
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _priceController,
                                  decoration: const InputDecoration(
                                    labelText: 'Hinta (€)',
                                    hintText: 'Esim. 5.00',
                                    prefixIcon: Icon(Icons.euro),
                                    prefixText: '€ ',
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  validator: (value) {
                                    if (!_isFree && (value == null || value.trim().isEmpty)) {
                                      return 'Syötä hinta';
                                    }
                                    if (!_isFree && value != null && value.trim().isNotEmpty) {
                                      try {
                                        final price = double.parse(value.trim().replaceAll(',', '.'));
                                        if (price < 0) {
                                          return 'Hinta ei voi olla negatiivinen';
                                        }
                                      } catch (e) {
                                        return 'Virheellinen hinta';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Kuvan valinta
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: _selectedImage != null
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : _currentImageUrl != null
                                  ? Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(14),
                                          child: CachedNetworkImage(
                                            imageUrl: _currentImageUrl!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            placeholder: (context, url) => const Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                            errorWidget: (context, url, error) => const Icon(
                                              Icons.error,
                                              size: 48,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo,
                                          size: 56,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'Valitse kuva',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Tallenna-nappi
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _updateFoodItem,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(_isLoading ? 'Tallennetaan...' : 'Tallenna muutokset'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}