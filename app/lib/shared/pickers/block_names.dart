import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/app_theme.dart';

/// Localised name of a block colour, for screen readers and the picker.
String blockColorName(AppLocalizations l10n, BlockColor color) =>
    switch (color) {
      BlockColor.coral => l10n.colorCoral,
      BlockColor.tangerine => l10n.colorTangerine,
      BlockColor.amber => l10n.colorAmber,
      BlockColor.lime => l10n.colorLime,
      BlockColor.mint => l10n.colorMint,
      BlockColor.teal => l10n.colorTeal,
      BlockColor.sky => l10n.colorSky,
      BlockColor.indigo => l10n.colorIndigo,
      BlockColor.violet => l10n.colorViolet,
      BlockColor.magenta => l10n.colorMagenta,
      BlockColor.rose => l10n.colorRose,
      BlockColor.slate => l10n.colorSlate,
    };

/// Localised name of a block icon, for screen readers and the picker.
String blockIconName(AppLocalizations l10n, BlockIcon icon) => switch (icon) {
  BlockIcon.circle => l10n.iconCircle,
  BlockIcon.work => l10n.iconWork,
  BlockIcon.meeting => l10n.iconMeeting,
  BlockIcon.call => l10n.iconCall,
  BlockIcon.mail => l10n.iconMail,
  BlockIcon.code => l10n.iconCode,
  BlockIcon.study => l10n.iconStudy,
  BlockIcon.book => l10n.iconBook,
  BlockIcon.gym => l10n.iconGym,
  BlockIcon.run => l10n.iconRun,
  BlockIcon.walk => l10n.iconWalk,
  BlockIcon.bike => l10n.iconBike,
  BlockIcon.meal => l10n.iconMeal,
  BlockIcon.coffee => l10n.iconCoffee,
  BlockIcon.sleep => l10n.iconSleep,
  BlockIcon.medication => l10n.iconMedication,
  BlockIcon.heart => l10n.iconHeart,
  BlockIcon.home => l10n.iconHome,
  BlockIcon.clean => l10n.iconClean,
  BlockIcon.shopping => l10n.iconShopping,
  BlockIcon.commute => l10n.iconCommute,
  BlockIcon.flight => l10n.iconFlight,
  BlockIcon.music => l10n.iconMusic,
  BlockIcon.pet => l10n.iconPet,
  BlockIcon.star => l10n.iconStar,
};
