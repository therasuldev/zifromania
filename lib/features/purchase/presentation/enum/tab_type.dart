enum TabType {
  subscription,
  coins;

  int get idx => switch (this) {
        TabType.subscription => 0,
        TabType.coins => 1,
      };
}
