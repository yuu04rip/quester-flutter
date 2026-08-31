# Quester – Progetto Mobile (Flutter)

## Descrizione del Progetto

Quester è un'applicazione mobile sviluppata in Flutter che unisce la gestione delle attività quotidiane a meccaniche di gamification. L'obiettivo principale è contrastare la procrastinazione trasformando le routine personali in missioni, fornendo ricompense e tracciando i progressi per favorire abitudini positive.

## Obiettivo

Sviluppare un'applicazione cross-platform in Flutter basata su un'architettura pulita e scalabile, integrando organizzazione personale, persistenza locale dei dati e un sistema di progressione basato su livelli e valuta virtuale.

## Funzionalità Principali

### Gestione Missioni

* **Tipologie di missioni:** Missioni Giornaliere, Settimanali e Speciali.
* **Subtask:** Tracciamento dei singoli passaggi interni ad ogni missione con barra di avanzamento dinamica.
* **Azioni:** Creazione, modifica, eliminazione con supporto all'undo tramite Snackbar, completamento automatico e reset.

### Gamification

* **Sistema XP:** Punti esperienza con progressione lineare calcolata tramite la formula dedicata e livello massimo fissato a 50.
* **Valuta in-game:** Guadagno di monete attraverso il completamento delle attività e il superamento dei livelli.
* **Ricompense:** Assegnazione di XP e monete differenziata in base alla tipologia di missione.

### Profilo e Personalizzazione

* Gestione delle informazioni utente e visualizzazione delle statistiche complessive.
* **Avatar personalizzabile:** Modifica di cornici, cosmetici del personaggio e temi grafici dell'applicazione (Arcade, Fantasy, Regale, Base).
* Gestione dell'account con opzioni di disconnessione ed eliminazione.

### Negozio

* Catalogo per l'acquisto di elementi estetici utilizzando la valuta accumulata nel corso delle attività.
* Verifica automatica del saldo e dello stato di possesso degli oggetti.

## Tecnologie e Architettura

L'applicazione adotta una separazione netta dei layer basata su widget, servizi e pattern di repository:

* **Data Layer:** Persistenza locale gestita tramite SQLite (`sqflite` e `sqflite_common_ffi`) con organizzazione basata su DAO, modelli e provider del database.
* **Preferences & Session:** Gestione delle preferenze e delle sessioni utente tramite `shared_preferences` e provider dedicati.
* **Repository Pattern:** Astrazione dell'accesso ai dati per utenti, missioni e autenticazione (`UserRepository`, `MissionRepository`, `AuthRepository`).
* **Autenticazione:** Sistema sicuro basato su hashing delle password tramite `crypto` e orchestrazione affidata ad `AuthService`.
* **Servizi di Business Logic:** Gestione centralizzata di missioni, economia di gioco, acquisti e promemoria locali in background tramite `flutter_local_notifications`.
* **User Interface:** Interfaccia reattiva sviluppata interamente con Flutter Material Design e temi personalizzati.

## Requisiti Tecnici

| Componente | Versione / Specifica |
| --- | --- |
| Flutter SDK | ^3.13.0 |
| Dart SDK | ^3.13.0 |
| SQLite (sqflite) | ^2.3.0 |
| Local Notifications | ^17.0.0 |
| Shared Preferences | ^2.5.3 |
| Crypto | ^3.0.3 |
| Provider | ^6.0.0 |

## Testing

La robustezza del codice è validata attraverso una suite di test strutturati:

* **Unit Test:** Validazione della logica di business, calcolo degli XP e dei livelli.
* **Widget Test:** Verifica del corretto rendering dei componenti grafici e delle schermate principali.

## Struttura del Progetto

```text
lib/
├── data/
│   ├── dao/          # Data Access Objects (SQLite)
│   ├── database/     # Database principale e provider
│   ├── models/       # Entità del database e modelli dati
│   ├── preferences/  # Gestione preferenze tema
│   └── session/      # Gestione sessione utente
├── domain/
│   └── service/      # Servizi di logica applicativa
├── repository/       # Repository di accesso ai dati
├── ui/
│   ├── screens/      # Schermate dell'applicazione (Auth, Profile, Mission, Shop, NavBar)
│   └── theme/        # Definizione di colori, tipografia e temi
├── widgets/          # Componenti grafici riutilizzabili (Avatar, Cornici)
└── main.kt / main.dart # Entry point dell'applicazione

```

## Team di Sviluppo

* Giovanni De Luca
* Gabriele Di Carlo