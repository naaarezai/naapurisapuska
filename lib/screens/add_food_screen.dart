import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../models/food_item.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/user_service.dart';
import '../utils/haptic_helper.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage; // Yksittäinen kuva (takaisin yhteensopivuus)
  List<File> _selectedImages = []; // Useita kuvia
  FoodCategory _selectedCategory = FoodCategory.muut;
  String _quantityUnit = 'kg'; // Oletusyksikkö
  bool _isLoading = false;
  double _uploadProgress = 0.0;
  String _loadingMessage = 'Ladataan kuvaa ja tallennetaan...';
  final DatabaseService _databaseService = DatabaseService();
  final UserService _userService = UserService();
  bool _isFree = true; // Ilmainen vai maksullinen

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // Funktio kuvan valitsemiseen (kamera tai galleria)
  Future<void> _pickImage() async {
    // Näytä valintaikkuna: Kamera vai Galleria
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ota kuva'),
              onTap: () {
                HapticHelper.selectionClick();
                Navigator.pop(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Valitse galleriasta'),
              onTap: () {
                HapticHelper.selectionClick();
                Navigator.pop(context, ImageSource.gallery);
              },
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
      final imageFile = File(pickedFile.path);
      setState(() {
        if (_selectedImages.length < 5) {
          _selectedImages.add(imageFile);
          _selectedImage = imageFile; // Takaisin yhteensopivuus
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Voit lisätä enintään 5 kuvaa'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }
  
  // Poista kuva listasta
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      if (_selectedImages.isNotEmpty) {
        _selectedImage = _selectedImages.first;
      } else {
        _selectedImage = null;
      }
    });
  }

  // Hae käyttäjän nykyinen sijainti
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Sijaintipalvelut eivät ole käytössä');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Sijaintilupa evätty');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Sijaintilupa evätty pysyvästi');
    }

    return await Geolocator.getCurrentPosition();
  }

  // Lähetä ilmoitus Firebaseen
  Future<void> _submitFoodItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Valitse vähintään yksi kuva ennen ilmoituksen jakamista'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Hae sijainti
      final position = await _getCurrentLocation();

      // Hae käyttäjän tiedot
      final user = FirebaseAuth.instance.currentUser;
      UserModel? userModel;
      if (user != null) {
        userModel = await _userService.getCurrentUser();
        // Jos käyttäjää ei ole vielä tietokannassa, luo se
        if (userModel == null) {
          userModel = UserModel(
            id: user.uid,
            phoneNumber: user.phoneNumber,
            createdAt: DateTime.now(),
          );
          await _userService.createOrUpdateUser(userModel);
        }
      }

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

      // Parsii määrän
      double? quantity;
      String? quantityUnit;
      if (_quantityController.text.trim().isNotEmpty) {
        try {
          quantity = double.parse(_quantityController.text.trim().replaceAll(',', '.'));
          quantityUnit = _quantityUnit;
        } catch (e) {
          // Määrä on valinnainen, jatka ilman sitä
        }
      }

      // Luo FoodItem-olio
      final foodItem = FoodItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        imageUrl: '', // Päivitetään DatabaseServicessä
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
        category: _selectedCategory,
        userId: user?.uid,
        userName: userModel?.name,
        userProfileImageUrl: userModel?.profileImageUrl,
        price: price,
        quantity: quantity,
        quantityUnit: quantityUnit,
      );

      // Tallenna Firebaseen edistymisen seurannalla
      await _databaseService.addFoodItemWithMultipleImages(
        foodItem,
        _selectedImages,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _uploadProgress = progress;
              if (progress < 0.5) {
                _loadingMessage = 'Optimoidaan ja ladataan kuvaa...';
              } else if (progress < 0.9) {
                _loadingMessage = 'Tallennetaan tietoja...';
              } else {
                _loadingMessage = 'Viimeistellään...';
              }
            });
          }
        },
      );

      if (mounted) {
        // Näytä onnistumisilmoitus animaatiolla
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ilmoitus jaettu onnistuneesti!',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32), // Vihreä väri
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        
        // Odota hetki ennen navigointia, jotta käyttäjä näkee ilmoituksen
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
          _loadingMessage = 'Ladataan kuvaa ja tallennetaan...';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lisää uusi ilmoitus'),
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
                      
                      // Määrä
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _quantityController,
                              decoration: const InputDecoration(
                                labelText: 'Määrä',
                                hintText: 'Esim. 2.5',
                                prefixIcon: Icon(Icons.scale),
                              ),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _quantityUnit,
                              decoration: const InputDecoration(
                                labelText: 'Yksikkö',
                              ),
                              items: const [
                                DropdownMenuItem(value: 'kg', child: Text('kg')),
                                DropdownMenuItem(value: 'kpl', child: Text('kpl')),
                                DropdownMenuItem(value: 'litra', child: Text('litra')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _quantityUnit = value;
                                    HapticHelper.selectionClick();
                                  });
                                }
                              },
                            ),
                          ),
                        ],
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
                              HapticHelper.selectionClick();
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Hinta (ilmainen vai maksullinen)
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
                                          HapticHelper.selectionClick();
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

                      // Kuvien valinta
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Kuvat',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_selectedImages.isNotEmpty)
                                Text(
                                  '${_selectedImages.length}/5',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Kuvien grid
                          _selectedImages.isEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    HapticHelper.lightImpact();
                                    _pickImage();
                                  },
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
                                    child: const Column(
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
                                )
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 1,
                                  ),
                                  itemCount: _selectedImages.length + (_selectedImages.length < 5 ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index < _selectedImages.length) {
                                      // Näytä valittu kuva
                                      return Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.file(
                                              _selectedImages[index],
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            ),
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: GestureDetector(
                                              onTap: () => _removeImage(index),
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      // Lisää kuva -nappi
                                      return GestureDetector(
                                        onTap: () {
                                          HapticHelper.lightImpact();
                                          _pickImage();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 2,
                                              style: BorderStyle.solid,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.grey,
                                            size: 32,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Jaa-nappi
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : () {
                          HapticHelper.mediumImpact();
                          _submitFoodItem();
                        },
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
                            : const Icon(Icons.check_circle),
                        label: Text(_isLoading ? 'Tallennetaan...' : 'Jaa ilmoitus'),
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