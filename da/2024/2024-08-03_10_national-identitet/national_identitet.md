# National Identitet
TP, 2024-08-03

:it-politik:
:it-suverænitet:

# Konklusion
* Danmark har brug for en IT politik.
* Danmark har brug for en national identitet.

# Baggrund
Vi har MitID, vi havde NemID, men vi mangler en national identitet med følgende egenskaber:
* Garanteret af staten (som MitID og NemId)
* Detaljeret i data som deles.
* Klart for brugeren hvilke data som deles i en given transaktion.
* Let at bruge for brugere og services.
* Baseret på åbne standarder (fx OAuth2).

# Vision
* Tænk hvis vi på mange services ikke blot kan logge ind med "Facebook" og "Google", men også med "Danmark".
* Tænk hvis vi ikke behøver oprette en ny bruger alle mulige steder eller være afhængig af "tech-giganterne".
* Tænk hvis du kan dele en fil med din ven uden at skulle dele den med tech-giganterne eller sende den i en mail.

# Tanker
Det åbne internet er fint til mange ting, og man har en stor grad af anonymitet.
Men transaktioner, der kræver tillid, kræver at man ved hvem man interagerer med.

En elektronisk identitet er grundlaget for mange nyttige services på internettet:
* Email
* Sociale netværk
* Fildeling
* Videoopkald

I dag har vi hver især mange identieter på internettet:
* Mail-konti enten hostet hos udbydere eller på eget domæne.
* Bruger-konti på sociale netværk som Facebook, Twitter, Instagram.
* Bruger-konti på operativsystemer fra fx Microsoft, Google eller Apple.
* Bruger-konti på fil-delings services som Dropbox, Google drive, Apple Cloud, Microsoft Sharepoint.
* Bruger-konti i forskellige foreninger som idrætsforening, spejdergruppe, politisk organisation.
* Bruger-konti hos forskellige betalte services som aviser, streaming, spil.

Der er sikkert flere.
Fælles for dem er at de giver en persistent identiet, som gør det muligt for servicen at følge hver enkelt bruger, og for de enkelte brugere at interagere med hinanden inden for servicen.
De beder alle om forskellige niveauer af personlig information, og de fleste af dem stoler på hvad man skriver til dem uden at verificere det.
Det giver på den ene side os some brugere en del kontrol over hvad vi deler, men også en begrænset sikkerhed for hvem det er vi interagerer med.
Der hvor der er betaling involveret er der en ekstra identitetskontrol i form at en konto hos en bank eller et kreditkortselskab.
Der er ikke nogen sammenhæng mellem konti på forskellige platforme, og der er ikke noget til hinder for at man giver sig ud for at være en, man ikke er.

Med en national identitet vil vi kunne have samme identiet på alle services.
Vi ville have kontrol over hvilke informationer der deles med hver service.
Service udbyderne ville have garanti for at personen er hvem vedkomne giver sig ud for.
Hvis man gør noget ulovligt på en service, kan politiet komme efter en.

# Detaljer
Hvordan skal det virke?

## Staten garanterer identiteten

Som med MitId, NemId skal staten garantere identieten.
Det kan fx ved at opsætningen kobles til et pas eller assisteres af en myndighed.
En identiet skal kunne invalideres ved død eller dom.
Både borgere og virksomheder har en national identiet.
Den centrale database kan passende være CPR og CVR.
Alle har en og kun en identitet.

## Eksplicit og detaljeret deling af data
Den nationale identitet er ikke hemmelig eller fortrolig, men indholdet styres af borgeren.
Enhver som har en national identiet kan slå andre nationale identiteter op og få at vide om den eksisterer.
Men data på den nationale identitet skal autoriseres af brugeren per transaktion.
Det kan fastsættes per lov at politi og myndigheder kan trække information uden borgerens samtykke.

Det skal selvfølgelig være muligt at opsætte regler, så visse transaktioner er forhåndsgodkendt.

Deling af data skal være detaljeret.
En service fx kunne få svar på om personen bag en national identitet er over 18 år uden at få andet oplyst, hvis borgeren godkender det.
En idrætsforening kan fx trække adresse, alder, skoleklasse, køn og Id på forældrene, hvis borgeren godkender det.
Foreningen behøver kun at have national id på medlemmerne, alt andet kan trækkes online, når det skal bruges. Borgeren kan forhåndsautorisere det, og trække autorisationen tilbage, når vedkomne melder sig ud.

## Let at bruge og baseret på åbne standarder
For at få fuld værdi af en national identiet skal den være let at bruge både for borgerne og for diverse services.
Den skal baseres på åbne standarder som fx OAuth2, så man kan bruge eksisterende værktøjer til opsætning og integration.
Staten skal stille et administrationsværktø til rådighed, hvor man let kan styre hvem man giver hvilke tilladelser.

Vi borgere skal kunne bruge vores identitet til at identificere os med, fx ved at trække certifikater til eletronisk signatur.

# Implementation
Vi skal huske at ikke alle sidder ved en computer hele dagen.
Det skal være let at få hjælp af kommunen eller familiemedlemmer med administrationen.

Biometri vil være en måde at lave et relativt simpelt interface med.
Det er i praksis hvad der bruges i dag på diverse smartphones.
For de paranoide kan vi lave andre løsninger.

