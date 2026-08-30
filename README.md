# Thème GRUB Musée Bolo

Contenu :
- `theme.txt` : thème GRUB
- `logo.png` : logo recadré avec fond transparent

## Installation

```bash
sudo mkdir -p /boot/grub/themes/museebolo
sudo cp theme.txt logo.png /boot/grub/themes/museebolo/
```

Éditer `/etc/default/grub` et ajouter ou modifier :

```bash
GRUB_THEME="/boot/grub/themes/museebolo/theme.txt"
GRUB_GFXMODE=auto
GRUB_GFXPAYLOAD_LINUX=keep
GRUB_TIMEOUT_STYLE=menu
GRUB_TIMEOUT=3
```

Puis :

```bash
sudo update-grub
```

et redémarrer.

## Remarques

- `GRUB_GFXMODE=auto` laisse GRUB utiliser un mode graphique disponible sur l'écran.
- Le thème ne force pas une résolution 1920×1080.
- Le logo a une taille fixe de 420×420 px afin de rester utilisable sur des écrans modestes,
  notamment 800×600 et 1024×768.
- Si un écran 640×480 doit aussi être pris en charge, utilisez plutôt une version du logo
  de 320×320 px et ajustez `left`, `top`, `width` et `height` dans `theme.txt`.
- En cas de problème, le menu GRUB reste accessible ; conservez idéalement une console
  ou un accès de secours avant de masquer davantage le menu.
