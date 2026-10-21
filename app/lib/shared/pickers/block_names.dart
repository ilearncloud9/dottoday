import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';

/// Localised name of a task colour, for screen readers and the picker.
String taskColorName(AppLocalizations l10n, TaskColor color) => switch (color) {
  TaskColor.coral => l10n.colorCoral,
  TaskColor.amber => l10n.colorAmber,
  TaskColor.mint => l10n.colorMint,
  TaskColor.teal => l10n.colorTeal,
  TaskColor.sky => l10n.colorSky,
  TaskColor.indigo => l10n.colorIndigo,
  TaskColor.violet => l10n.colorViolet,
  TaskColor.rose => l10n.colorRose,
  TaskColor.slate => l10n.colorSlate,
};

/// Localised name of a task icon, for screen readers and the picker.
String taskIconName(AppLocalizations l10n, TaskIcon icon) => switch (icon) {
  TaskIcon.code => l10n.iconCode,
  TaskIcon.run => l10n.iconRun,
  TaskIcon.mail => l10n.iconMail,
  TaskIcon.call => l10n.iconCall,
  TaskIcon.meal => l10n.iconMeal,
  TaskIcon.book => l10n.iconBook,
  TaskIcon.list => l10n.iconList,
  TaskIcon.language => l10n.iconLanguage,
  TaskIcon.heart => l10n.iconHeart,
  TaskIcon.travel => l10n.iconTravel,
  TaskIcon.cart => l10n.iconCart,
  TaskIcon.home => l10n.iconHome,
  TaskIcon.tv => l10n.iconTv,
  TaskIcon.bag => l10n.iconBag,
  TaskIcon.music => l10n.iconMusic,
  TaskIcon.meds => l10n.iconMeds,
  TaskIcon.water => l10n.iconWater,
  TaskIcon.pet => l10n.iconPet,
  TaskIcon.gym => l10n.iconGym,
  TaskIcon.car => l10n.iconCar,
  TaskIcon.money => l10n.iconMoney,
  TaskIcon.gift => l10n.iconGift,
  TaskIcon.camera => l10n.iconCamera,
  TaskIcon.star => l10n.iconStar,
  TaskIcon.people => l10n.iconPeople,
  TaskIcon.document => l10n.iconDocument,
  TaskIcon.circle => l10n.iconCircle,
};
