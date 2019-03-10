#pragma once

#include <unordered_set>;

class App
{
  public:
  App()
  {
    
  }

  void run() 
  {
    // Print main menu to the console
  std::cout << " ___________ \n";
  std::cout << "|           |\n";
  std::cout << "| LOL DRAFT |\n";
  std::cout << "|___________|\n";
  std::cout << "             \n";

  // Display options
  std::cout << "(1): All-Random Draft\n";
  std::cout << "(2): Single Draft\n";
  std::cout << "(3): All-Random\n";
  std::cout << "(H): Help\n";
  std::cout << std::endl;
  std::cout << "Select an option: ";

  // Get user input
  std::string input;
  std::cin >> input;
  }
}