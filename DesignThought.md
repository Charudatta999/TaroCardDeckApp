# UI Design & Flow for Hindu Mythic Tarot App

## Visual Theme & Branding
We’ll run a **modern dark theme** with luxe Indian myth vibes.  The palette is deep pitch-black/velvet as the base, with *saffron-orange* and **gold accents** (to echo om’s traditional color) for highlights.  Saffron has deep cultural meaning in Hinduism (it represents fire and asceticism【1†L69-L77】), so the Om icon and glow use saffron/gold to reinforce authenticity.  High-contrast white or soft cream text on black ensures readability.  The style is “temple-chic” – think sleek UI layouts mixed with temple-mythic icons (Lotus, Trishul, Om symbols, serpent motifs, etc.). We keep fonts clean and legible (e.g. a modern sans with subtle curves) for headings and a neutral serif or humanist font for body text, giving a premium vibe without feeling cartoony.  The user sees this as a **serious, respectful ritual tool** but with a fresh, cutting-edge UI aesthetic.

- **Color scheme:** Deep black background (#000000) with gold/saffron highlights (#FFD700/#FF4500), occasional deep maroon or midnight blue accents.
- **Graphics style:** Intricate line-art or semi-transparent deity silhouettes as background watermarks on cards, lotus and mandala patterns in overlay, snakes entwining selection trays. This mixes traditional iconography with a clean digital look.
- **Typography:** Primary heading font (e.g. Merriweather or Lora) in gold/white, body text in a modern sans (like Roboto) for clarity. Sanskrit transliterations can use a classic Devanagari-style typeface for card titles (alongside Latin letters).
- **Iconography:** Stylized Om, diya (lamp), conch, temple bells, etc., in minimal vector style so they pop against dark BG. All custom graphics match the “sacred yet sleek” theme.

## Opening Animation & Splash
The **splash screen** opens with a *full-screen golden Om* on black. This Om gently **fades in/out and pulses** with a saffron glow (like sunlight halo or subtle bokeh behind it). The effect is mystical but elegant – for example, imagine soft animated particles (golden dust or light bokeh) radiating outward from the Om, giving a divine energy vibe. The Om’s glow should be saffron-orange with slight bloom, as if lit by temple lamps.

- **Animation details:** Om appears and scales up slightly while increasing glow (duration ~800ms), then gently **fades to reveal main menu**. Use ease-in-out timing to feel organic.
- **Sound & haptics:** A brief soft **temple bell ding** or low Om chant sound plays as Om appears (subtle, short), synced with a tiny vibration on appear/tap for tactile punch. According to Android guidelines, this haptic should be very short (~10-20ms) so it’s noticeable but not jarring【10†L909-L911】.
- **Transition:** After Om fade-out, crossfade into the home/deck screen.

The goal is an *immersive intro* that immediately sets tone: “This is not a cartoon app, it’s a serious, zen ritual tool.” But keep it polished and fast, so users stay engaged (total splash ~1–1.2s).

## Main Deck Screen (Divination Mode)
When the app opens into **Divination mode** (the default), we see a **hamburger menu icon** top-left (for drawer menu: Divination, Catalogue, etc.), and the main content is a deck of cards. The deck is presented as a stack of **6 cards** overlapping (like a fan), offset so each card’s corner peeks out (for a visual cue there are multiple cards). The stack sits center-screen on a soft-patterned dark background.

- **Scrollable deck:** The 6-card stack is actually horizontally scrollable. Material Design explicitly supports horizontally scrolling card collections in a container【3†L121-L128】. The user can swipe left/right on the stack to view additional cards (so if the deck had more, but we show 6 at a time). Each card is maybe 160–180dp wide so that the edges of next cards peek.
- **Card visuals:** Card backs are uniform velvet-black with a **gold embossed Om** icon at center. Subtle card edge glow or border (thin gold outline) indicates selection or focus. The back shows minimal design so users focus on the art when flipped.
- **Hamburger & header:** The top bar says “Divination” or app name in gold text. The menu slides out from left on tap (with dark semi-transparent overlay behind it).
- **Empty state:** If no cards chosen, just show deck. Once cards are drawn (see below), hide deck or keep it moved aside.

We want this screen to feel like an altar or sacred table: minimal controls, decorative but not busy. Perhaps faint mandala or temple patterns in the background behind the deck.

## Shuffling & Card Draw Interaction
Clicking the deck (or a “Shuffle & Draw” button) triggers a **magical shuffle animation**. We envision cards gently floating and swirling. For example, cards might levitate, rotate slightly, and re-stack. A **MotionLayout** or physics system can do this: a top card slides out and back in while the next card scales up (as shown in a sample MotionLayout shuffle【5†L437-L444】). Specifically, you could animate the current front card drifting right then returning (slight spin or scale down), while the card behind it scales up to take the top position. Loop through 6 cards quickly.

- **Effect:** Gold particles or sparkles can trail each moving card. Shuffle sound: a light *whoosh* or *rattle* like soft temple beads jingling. Vibrate subtly once when shuffle completes.
- **Timing:** Total shuffle ~1–1.5s. Each card movement about 300ms with short easing.
- **After shuffle:** The deck ends up “shuffled” in place. Now user can **select cards**.

## Card Selection Flow
After shuffling, the user scrolls left/right on the deck to see different cards. Tapping a card **selects it**. On tap, that card animates upward into a **selection tray** at the top of the screen (or top of deck area). The tray is like a horizontal list with snake-border decorations (as requested). So maybe two golden snakes facing each other frame the tray edges.

- **Selected tray:** Appears once the first card is picked: it slides in from top (dark translucent panel with snake arms). Each tapped card joins the tray from the bottom with a smooth slide (ease-out).
- **No unselect:** Tapping is final (no undo). We can show a subtle confirmation haptic on tap. The card’s back should maybe flip to reveal front as it moves.
- **Layout:** The tray holds chosen cards horizontally. If the user selects multiple (maybe up to 3 or a spread count), they line up in the tray. Each card’s front art shows in the tray in miniature.

When the user is done picking (e.g. after a set number or clicking “done”), **the tray animates back down** to the main view to form the actual reading layout. For example, the tray could slide down to center and spread cards out in a fan or specific tarot spread pattern. The animation of cards moving from tray to layout maintains continuity (cards move, maybe rotate to their final orientation). This ensures clarity of what cards were chosen.

## Card Detail Screen
Tapping a dealt card on the main screen opens its **detail view**. This view is an overlay or new screen showing rich info:

- **Layout:** Full-screen card image (the front art) as the background, slightly darkened. An information panel (perhaps a semi-transparent scrollable sheet) appears over it. The panel’s top shows card title (e.g. “Omkar – Creation”).
- **Sections:** The content is in sections you scroll vertically:
  - **Key Meaning:** A short summary first, bullet-form or short paragraph about what the card means in readings. (This is the default view of detail.)
  - **Deity Association:** Scroll down to see “Deity: [Name]” and some biographical or attribute info about that god/dess (colorful text boxes or icons). This ties the card’s symbolism to mythology.
  - **Rituals & Mantra:** Next section lists recommended mantra (in Sanskrit and transliteration) and any ritual tips or affirmations.
  - **Symbolism/Background:** Finally, a box with extra symbolism (animal, object associations) or historical notes.
- **Visuals:** The scrolling background could subtly shift – e.g. parallax effect or faint glow pulses behind deity images as user scrolls, reinforcing immersion. The card’s deity artwork can fade in at appropriate sections.
- **Consistency:** The detail page uses the same dark background with saffron/gold accent headings. Sanskrit words in Devanagari script might appear in orange or gold font.

Example text structure:
```
**Meaning:** (body text)
*“This card represents new beginnings and spiritual growth, encouraging the seeker to trust the journey.”*

**Deity:** Ganesha – Remover of obstacles, deity of wisdom【1†L69-L77】. He embodies overcoming hurdles.

**Mantra & Ritual:** *Mantra:* "Om Shri Ganeshaya Namaha". *Tips:* Light an incense and chant 3 times for clarity.

**Symbols:** Elephant head (wisdom), lotus (purity), mouse (humility) are depicted.
```
This layout ensures the user learns both the abstract meaning *and* the cultural mythology behind each card. It remains **user-friendly** by layering info (we don’t overwhelm on one screen) and letting them scroll. All interactive elements (back button, share icon perhaps) follow Material patterns for consistency.

## Catalogue Mode
The **Catalogue** (other menu option) is like a reference library of all cards. Its home shows one card at a time (front view, perhaps large), with a search bar on top.

- **Search:** Users can search by card name (English or Sanskrit), deity name, or keyword. The search field is on the app bar. Filtering happens live (or hitting enter).
- **Swipe Navigation:** Once a card is on screen, the user can swipe left/right to navigate through cards (like a carousel). Swiping horizontally goes to previous/next card in the tarot deck. This is intuitive and parallels photo gallery UX. (Vertical scroll is reserved for detail view).
- **Tap to Flip:** Tapping the centre of the card flips it (2D or 3D flip animation) to show back (which for catalogue could be the same as front but with details, or it might immediately open the same detail panel as above). Perhaps tapping triggers exactly the same detail overlay/page we described, keeping consistency.
- **Layout & Theme:** Even though catalogue is a separate mode, it maintains the dark + gold theming. The background could be a subtle repeating motif (like lotus petals), differentiating it from the Divination screen (which is plain).

In summary, Catalogue = “Browse all cards” view: large card image, search, swipe, tap for details. Ensure the UI clarifies that this is an index (maybe a breadcrumb or title “Catalogue”).

## Navigation & UX Flow
- **Hamburger Menu:** On all screens, the top-left hamburger opens a side drawer (nav rail) with *Divination* (default), *Catalogue*, *Settings* (if we add later), *About*, etc. Icons + text. Drawer slides over content with a slight dark overlay.
- **Divination Mode:** Main tab, always first on launch. Shows deck and/or current reading (if cards drawn).
- **Catalogue Mode:** As above. If the user is reading cards and switches to Catalogue, they should be warned their current session resets (or we auto-save reading). Probably simpler: switching to Catalogue auto-resets deck.
- **No Excess Tabs:** For now we keep it minimal (they said no need for history, daily, etc. yet). Possibly a settings gear, share button on cards.

UX Cornerstones:
- **Feedback:** All button taps show ripple (Material) + tiny haptic.
- **Consistency:** Use the same approach for highlighting selected cards, like golden outlines or glows.
- **Accessibility:** High contrast text, scalable font. We do have Sanskrit, so ensure fallback.
- **Language Toggle:** A settings screen (future) to toggle English/Hindi/Sanskrit, but for now each card shows both names by default.

## Animations & Motion
We weave **purposeful animations** throughout to delight the user and explain transitions (per Material Motion guidelines):

- **State Changes:** Whenever a UI state changes (like deck shuffling, card moving, menu opening), the animation should reflect cause-effect. Eg, selecting a card causes that card image to slide up.
- **Easing:** Smooth easing for everything (ease-in-out, ease-out), no abrupt moves.
- **Duration:** Most UI animations ~200–500ms. Shuffle is longer (~1s) since it’s marquee; navigation (drawer, flips) ~300ms.
- **Layering:** Use crossfades for mode changes (e.g., Divination -> Catalogue crossfade or quick slide). Use small delays so sequential card animations don’t feel simultaneous chaos.
- **Visual Interest:** Particle/bokeh overlays on splash and shuffle. Snake border could animate (a slow pulse along its curves when active). Card flip is a quick 180° rotation.
- **MotionLayout/Lottie:** For dev, complicated sequences (like shuffle) could use MotionLayout or Lottie animations to keep performance high.

The goal: Animations should feel *magical but not gimmicky* – more like smooth choreographed UI flow. They reinforce the spiritual vibe (e.g. a drawn card might gently emit a glow upon selection, hinting at its power).

## Sound & Haptic Feedback
We add *audio and tactile layers* for immersion:

- **Click & Card Sounds:** Soft *whoosh* for shuffle, *page-flip* or *bell ding* when a card is drawn/selected. The opening Om chant or temple bell on splash was mentioned. All sounds should be subtle (matching dark mode) and can be muted in settings.
- **Haptics:** Consistent with Android’s guidance【10†L751-L755】【10†L909-L911】. Key taps (card draw, menu open) get a short *click* vibration (~10ms). Don’t overdo it – we follow “less is more” so each action has at most one subtle buzz. Use **HapticFeedbackConstants** (e.g. `VIRTUAL_KEY`) for standard taps. We avoid “legacy one-shot” vibrations in favor of rich haptics (but since phones have limited ones, simple keyclick is fine)【10†L909-L911】.
- **Sync with Visuals:** For example, when a card finishes moving to the tray, play haptic *as* it snaps into place (making it feel solid). All haptics and sounds are tightly synchronized with animations to avoid mismatch【10†L886-L894】.

## Assets & Technical Specs
**Card Images:** Each card front is a high-res image (recommend 1080×1920 px at 2x density, PNG or WebP). The back is a reusable image (velvet black with Om).
**UI Icons:**  (Menu, search, share) – use vector drawables in gold or white.
**Animations:** Motion resources (MotionLayout XML) or Lottie JSON;  consider `AnimatedVectorDrawable` for simple ones.
**Timings:** Provide the dev team with exact durations: e.g. shuffle (1s total), splash (fade in 0.8s, hold 0.3s, fade out 0.4s), card selection slide (0.3s), tray slide (0.4s).
**Fonts:** Include TTF/OTF for Devanagari and transliteration. Eg: “Mukta Vaani” (Devanagari) and “Noto Sans” (Latin) as assets.
**Haptic Implementation:** Use `performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY)` for taps. For events like card draw, maybe a stronger `CONTEXT_CLICK` effect if subtle needed (but likely not needed).

**Offline Support:** All data (card images, text content) is bundled. No network needed. The app should load instantly on launch (splash is mostly decorative).
**Localization:** We’ll use resource strings for English/Sanskrit. Card names shown bilingually (e.g. “Ganesh – गणेश”).
**Performance:** Keep frame drops minimal. Limit heavy shadows or blur (drop for dark mode). Test animations on mid-range devices to ensure smooth.

## Summary
In summary, the UI is a **sacred meets sleek** experience: a dark, high-contrast interface accented with saffron/gold to honor Hindu myth themes. We use natural, enriching animations (Om glow, card shuffle, gentle parallax) to engage users. Navigation is lean – a sidebar and two modes (Divination and Catalogue). Each element (color, animation, haptic) is chosen to feel “lit and meaningful” yet polished. This approach synergizes modern mobile UI best practices (responsive card layouts, Material Design motions, brief haptics) with cultural authenticity (traditional symbols, mythic color meanings【1†L69-L77】). The result is a vibe that’s forward-thinking *and* reverential – a truly **next-gen spiritual tarot experience** that’s innovative yet comfortable for all users.