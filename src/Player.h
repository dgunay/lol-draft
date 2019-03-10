#pragma once

#include "Champion.h";

class Player
{
  public:
  Player();
  
  void selectChampion(Champion champion);

  private:
  Champion selectedChampion;
}