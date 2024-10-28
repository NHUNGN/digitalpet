
import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Pet App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DigitalPetApp(),
    );
  }
}

class DigitalPetApp extends StatefulWidget {
  const DigitalPetApp({super.key});

  @override
  State<DigitalPetApp> createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  String petType = "";
  int happinessLevel = 60;
  int hungerLevel = 50;
  int energyLevel = 100;
  int healthLevel = 100;
  Timer? hungerTimer;
  Timer? energyTimer;
  TextEditingController _nameController = TextEditingController();
  bool _nameSet = false;
  bool _typeSet = false;
  final int happinessThreshold = 10;
final int hungerThreshold = 10;
final int healthThreshold = 10;
bool hasRunAway = false;


  bool _overfedWarningShown = false;
  bool _starvedWarningShown = false;
  bool _unhappyWarningShown = false;
  bool _goodJobShown = false;

  int coins = 100;

@override
void initState() {
  super.initState();
  _startTimers();
  
  // Timer for gaining coins
  Timer.periodic(const Duration(minutes: 1), (Timer timer) {
    setState(() {
      coins += 1; // Gain 2 coins every 15 minutes
    });
  });
}


  @override
  void dispose() {
    hungerTimer?.cancel();
    energyTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

void _playWithPet(String playType) {
  setState(() {
    int happinessIncrease;
    int energyDecrease;
    // Assign values based on play type
    switch (playType) {
      case "Balls":
        happinessIncrease = 15;
        energyDecrease = 10;
        break;
      case "Pet":
        happinessIncrease = 10;
        energyDecrease = 5;
        break;
      case "Cuddle":
        happinessIncrease = 5;
        energyDecrease = 2;
        break;
      default:
        happinessIncrease = 10;
        energyDecrease = 5;
    }
    
    happinessLevel = (happinessLevel + happinessIncrease).clamp(0, 100);
    energyLevel = (energyLevel - energyDecrease).clamp(0, 100);
    
    // Ensure other logic for health and warnings
    _updateHealth();
    _resetWarningsIfNeeded();
    _checkHappinessWarning();
    _checkGoodJob();
  });
}

  void _feedPet() {
    setState(() {
      if (hungerLevel == 0) {
        happinessLevel = (happinessLevel - 5).clamp(0, 100);
        _showOverfedWarning();
      } else {
        hungerLevel = (hungerLevel + 10).clamp(0, 100);
        happinessLevel = (happinessLevel + 5).clamp(0, 100);
      }
      _updateHealth();
      _resetWarningsIfNeeded();
      _checkHappinessWarning();
      _checkGoodJob();
    });
  }

  void _resetWarningsIfNeeded() {
    if (hungerLevel != 0 && _overfedWarningShown) {
      _overfedWarningShown = false;
    }
    if (hungerLevel != 100 && _starvedWarningShown) {
      _starvedWarningShown = false;
    }
    if (happinessLevel > 10 && _unhappyWarningShown) {
      _unhappyWarningShown = false;
    }
  }

  void _startTimers() {
    hungerTimer = Timer.periodic(const Duration(seconds: 90), (Timer timer) {
      setState(() {
        if (hungerLevel == 0) {
          happinessLevel = (happinessLevel + 5).clamp(0, 100);
          hungerLevel = (hungerLevel - 5).clamp(0, 100);
          _showOverfedWarning();
        } else {
          hungerLevel = (hungerLevel - 5).clamp(0, 100);
          _updateHappinessDueToHunger();
          if (hungerLevel == 0) {
            _showStarvedWarning();
          }
        }
        _updateHealth();
        _resetWarningsIfNeeded();
        _checkHappinessWarning();
      });
      checkRunAwayStatus(); // Add this line to check runaway conditions
    });

    energyTimer = Timer.periodic(const Duration(seconds: 60), (Timer timer) {
      setState(() {
        energyLevel = (energyLevel - 5).clamp(0, 100);
        if (energyLevel <= 0) {
          _showEnergyWarning();
          energyLevel = 100; // Reset energy after warning
        }
      });
      checkRunAwayStatus(); // Add this line to check runaway conditions
    });
  }

void _updateHappinessDueToHunger() {
  if (hungerLevel <= 20) {
    happinessLevel = (happinessLevel - 5).clamp(0, 100); // Significant happiness drop
  } else if (hungerLevel <= 40) {
    happinessLevel = (happinessLevel - 3).clamp(0, 100); // Noticeable happiness drop
  } else if (hungerLevel <= 60) {
    happinessLevel = (happinessLevel - 2).clamp(0, 100); // Moderate happiness drop
  } else if (hungerLevel <= 80) {
    happinessLevel = (happinessLevel - 1).clamp(0, 100); // Minor happiness drop
  }
}
void updatePetStatus() {
  _updateHappinessDueToHunger(); 
}
void _updateHealthDueToHunger() {
  if (hungerLevel <= 20) {
    healthLevel = (healthLevel - 5).clamp(0, 100); // Significant health drop
  } else if (hungerLevel <= 40) {
    healthLevel = (healthLevel - 3).clamp(0, 100); // Noticeable health drop
  } else if (hungerLevel <= 60) {
    healthLevel = (healthLevel - 2).clamp(0, 100); // Moderate health drop
  } else if (hungerLevel <= 80) {
    healthLevel = (healthLevel - 1).clamp(0, 100); // Minor health drop
  }
}

void _updateHealth() {
  healthLevel = (hungerLevel).clamp(0, 100); // Health is equal to hunger level
}
void checkRunAwayStatus() {
  if (happinessLevel <= happinessThreshold || hungerLevel <= hungerThreshold || healthLevel <= healthThreshold) {
    setState(() {
      hasRunAway = true;
    });
    _showRunAwayDialog();
  }
}
void resetPet() {
  setState(() {
    petName = "Your Pet";
    happinessLevel = 60;
    hungerLevel = 50;
    energyLevel = 100;
    healthLevel = 100;
    coins = 100;
    hasRunAway = false;
  });
}




  void _showOverfedWarning() {
    if (!_overfedWarningShown) {
      _overfedWarningShown = true;
      _showWarningDialog('Warning', '$petName is overfed!');
    }
  }

  void _showStarvedWarning() {
    if (!_starvedWarningShown) {
      _starvedWarningShown = true;
      _showWarningDialog('Warning', '$petName is starved!');
    }
  }

  void _checkHappinessWarning() {
    if (happinessLevel <= 10 && happinessLevel > 0 && !_unhappyWarningShown) {
      _unhappyWarningShown = true;
      _showWarningDialog('Warning', '$petName is very unhappy!');
    }
  }

  void _checkGoodJob() {
    if (happinessLevel == 100 && !_goodJobShown) {
      _goodJobShown = true;
      _showWarningDialog('Good Job!', 'Your pet is very happy!');
    }
  }

  void _showEnergyWarning() {
    _showWarningDialog('Warning', '$petName is tired and needs to rest!');
  }

  void _showWarningDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Continue'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _showRunAwayDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Your Pet Ran Away!'),
        content: const Text('Your pet has run away due to low happiness, hunger, or health.'),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Reset'),
            onPressed: () {
              Navigator.of(context).pop();
              resetPet();
            },
          ),
        ],
      );
    },
  );
}


  Widget _petTypeSelectionScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Pet Type'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  petType = "Dog";
                  _typeSet = true;
                });
              },
              child: const Text('Dog'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  petType = "Cat";
                  _typeSet = true;
                });
              },
              child: const Text('Cat'),
            ),
          ],
        ),
      ),
    );
  }

Widget _getPetWidget() {

  String imagePath = petType == "Dog" ? "assets/dog.png" : "assets/cat.png";

  return Padding(
    padding: const EdgeInsets.only(top: 100.0), // Adjust this value to move the image down
    child: Center(
      child: Image.asset(
        imagePath,
        width: 200,
        height: 200,
      ),
    ),
  );
}


  // Build status indicator widget
  Widget _buildStatusIndicator(String label, int value, {Function? onTap}) {
    Color color;
    if (value >= 75) {
      color = Colors.green;
    } else if (value >= 50) {
      color = Colors.yellow;
    } else if (value >= 25) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return GestureDetector( // Add GestureDetector for tap functionality
      onTap: onTap != null ? () => onTap() : null,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$value%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // Function to show food options
void _showFoodOptions() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Choose Food'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Kibble (Cost: 5 coins)'),
              onTap: () {
                if (coins >= 5) {
                  setState(() {
                    hungerLevel = (hungerLevel + 10).clamp(0, 100);
                    coins -= 5; // Deduct coins
                  });
                  Navigator.of(context).pop();
                } else {
                  _showWarningDialog('Insufficient Coins', 'You do not have enough coins to buy Kibble.');
                }
              },
            ),
            ListTile(
              title: const Text('Canned Food (Cost: 10 coins)'),
              onTap: () {
                if (coins >= 10) {
                  setState(() {
                    hungerLevel = (hungerLevel + 20).clamp(0, 100);
                    coins -= 10; // Deduct coins
                  });
                  Navigator.of(context).pop();
                } else {
                  _showWarningDialog('Insufficient Coins', 'You do not have enough coins to buy Canned Food.');
                }
              },
            ),
            ListTile(
              title: const Text('Treats (Cost: 3 coins)'),
              onTap: () {
                if (coins >= 3) {
                  setState(() {
                    hungerLevel = (hungerLevel + 5).clamp(0, 100);
                    coins -= 3; // Deduct coins
                  });
                  Navigator.of(context).pop();
                } else {
                  _showWarningDialog('Insufficient Coins', 'You do not have enough coins to buy Treats.');
                }
              },
            ),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void _showPlayOptions() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Play with $petName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (petType == "Dog") ...[
              ListTile(
                title: const Text('Fetch'),
                onTap: () {
                  _playWithPetOption("Fetch");
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Walk'),
                onTap: () {
                  _playWithPetOption("Walk");
                  Navigator.of(context).pop();
                },
              ),
            ] else if (petType == "Cat") ...[
              ListTile(
                title: const Text('Pet'),
                onTap: () {
                  _playWithPetOption("Pet");
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Laser Pointer'),
                onTap: () {
                  _playWithPetOption("Laser Pointer");
                  Navigator.of(context).pop();
                },
              ),
            ],
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void _playWithPetOption(String option) {
  setState(() {
    if (option == "Fetch" || option == "Walk" || option == "Laser Pointer") {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);  // Increase happiness
      energyLevel = (energyLevel - 10).clamp(0, 100);        // Decrease energy
    } else if (option == "Pet") {
      happinessLevel = (happinessLevel + 5).clamp(0, 100);   // Slight increase in happiness
      energyLevel = (energyLevel - 5).clamp(0, 100);         // Slight decrease in energy
    }
  });
}

void _showVetOption() {
  if (coins < 50) {
    _showWarningDialog('Insufficient Coins', 'You need 50 coins to take your pet to the vet.');
    return;
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Visit Vet'),
        content: const Text('Do you want to restore your pet\'s health for 50 coins?'),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Yes'),
            onPressed: () {
              setState(() {
                coins -= 50;
                healthLevel = 100;
              });
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void _showEnergyOptions() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Energy Options'),
        content: const Text('Would you like to let your pet sleep for 15 minutes or pay 20 coins for full energy?'),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Sleep (15 mins)'),
            onPressed: () {
              Navigator.of(context).pop();
              _letPetSleep();
            },
          ),
          ElevatedButton(
            child: const Text('Pay 20 Coins'),
            onPressed: () {
              if (coins < 20) {
                _showWarningDialog('Insufficient Coins', 'You need 20 coins to restore energy.');
                Navigator.of(context).pop();
                return;
              }
              setState(() {
                coins -= 20;
                energyLevel = 100;
              });
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


bool isSleeping = false; // Initialize the variable
void _letPetSleep() {
  setState(() {
    isSleeping = true; // Set to true when the pet is going to sleep
  });

  Future.delayed(const Duration(minutes: 15), () {
    setState(() {
      energyLevel = 100; // Restore energy to full
      isSleeping = false; // Reset the sleep state
    });
  });
}


@override
Widget build(BuildContext context) {
  if (hasRunAway) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Your pet has run away!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: resetPet,
              child: const Text('Restart'),
            ),
          ],
        ),
      ),
    );
  }
  if (!_nameSet) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 179, 214),
      appBar: AppBar(
        title: const Text('Name Your Pet'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter your pet\'s name:',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Pet Name',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    petName = _nameController.text.isNotEmpty ? _nameController.text : 'Your Pet';
                    _nameSet = true;
                  });
                },
                child: const Text('Set Name'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  

  if (!_typeSet) {
    return _petTypeSelectionScreen();
  }

  return Scaffold(

    body: Stack(
      children: [
        // Background Image
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.png'), // Your background image path
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (isSleeping)
          Container(
            color: Colors.black54, // Adjust the opacity as needed
            child: const Center(
              child: Text(
                'Sleeping...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
                Positioned(
          top: 20,
          left: 20,
          child: Row(
            children: [
              Image.asset(
                'assets/coins.png', // Your coin image path
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 8),
              Text(
                '$coins',
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ],
          ),
        ),
        // Foreground content
        Column(
          children: [
            const SizedBox(height: 90), // Adding some space at the top
            Positioned(
              top: 20, 
              left: -50, 
              child: Container(
                padding: const EdgeInsets.all(8.0), 
                decoration: BoxDecoration(
                  color: Colors.white54, 
                  border: Border.all(color: Colors.black, width: 2), 
                  borderRadius: BorderRadius.circular(8), 
                ),
                child: Text(
                  '$petName',
                  style: const TextStyle(fontSize: 24, color: Colors.black), 
                ),
             ),
            ),
            const SizedBox(height: 70), 
            _getPetWidget(),
            const SizedBox(height: 260),
            Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatusIndicator('Hunger', hungerLevel, onTap: _showFoodOptions), 
                    _buildStatusIndicator('Happiness', happinessLevel, onTap: _showPlayOptions),
                     _buildStatusIndicator('Energy', energyLevel, onTap: _showEnergyOptions),
                    _buildStatusIndicator('Health', healthLevel, onTap: _showVetOption),

              ],
            ),
          ],
        ),
      ],
    ),
  );
}
}
