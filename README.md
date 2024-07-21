# BoxSFR_mode_Eco
## Ce script permet d'automatiser l'activation et la désactivation du mode Eco sur une box SFR.
Le mode Eco sur une box SFR permet d'économiser de l'énergie en désactivant les ports RJ45 non utilisés.

## Fonctionnement
Le script se lance tous les jours à 18 heures, si l'heure courante est supérieur ou égale à 18 alors le script désactive le mode Eco de la Box.
Par la suite le script se lance une deuxième fois à 1 heure du matin, test si l'heure courante est supérieur ou égale à 18 dans se cas c'est faux donc activation du mode Eco. 

## Logs
```Bash
journalctl -t 'SFR_ECO'
```

## Cron, exemple de configuration
```Bash
crontab -e

0 2 * * * /chemin/vers/le/script/auto_eco_box.sh
0 18 * * * /chemin/vers/le/script/auto_eco_box.sh
```
## Reste à faire
- [ ] Détecter l'état initial dans le but de tester l'état voulu.
