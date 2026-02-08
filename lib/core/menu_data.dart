class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
  });

  final String id;
  final String name;
  final String description;
  final String category;
}

class MenuCategory {
  static const String fastFood = 'FAST FOOD';
  static const String healthy = 'HEALTHY';
  static const String noodles = 'NOODLES';
  static const String rice = 'RICE';
  static const String random = 'CHAOS';
  static const String custom = 'CUSTOM';
}

const List<MenuItem> kPresetMenu = [
  // Fast Food
  MenuItem(
    id: 'mcd',
    name: '麦当劳',
    description: '金拱门的救赎。快速回复大量热量，但会增加“罪恶感”状态。',
    category: MenuCategory.fastFood,
  ),
  MenuItem(
    id: 'kfc',
    name: '肯德基',
    description: '疯狂星期四的契约者。酥脆的外壳下隐藏着高卡路里的真相。',
    category: MenuCategory.fastFood,
  ),
  MenuItem(
    id: 'bk',
    name: '汉堡王',
    description: '火焰烧烤的霸主。只有真正的肉食者才能驾驭的皇堡。',
    category: MenuCategory.fastFood,
  ),
  MenuItem(
    id: 'dicos',
    name: '德克士',
    description: '当你想换换口味时的选项。炸鸡与酱料的组合，有时会带来惊喜。',
    category: MenuCategory.fastFood,
  ),
  MenuItem(
    id: 'pizza',
    name: '披萨/意式快餐',
    description: '切片的仪式感。芝士拉丝能短暂修复上班的精神值。',
    category: MenuCategory.fastFood,
  ),
  MenuItem(
    id: 'fried_chicken',
    name: '炸鸡汉堡小店',
    description: '街头传说。随机出现的神秘小店，常常比连锁更“狠”。',
    category: MenuCategory.fastFood,
  ),

  // Healthy
  MenuItem(
    id: 'salad',
    name: '轻食沙拉',
    description: '大地的恩赐。虽然索然无味，但能净化体内的油脂毒素。',
    category: MenuCategory.healthy,
  ),
  MenuItem(
    id: 'subway',
    name: '赛百味',
    description: '自选的艺术。在面包与蔬菜的迷宫中寻找属于你的健康之路。',
    category: MenuCategory.healthy,
  ),
  MenuItem(
    id: 'poke',
    name: 'Poke Bowl',
    description: '海风的召唤。蛋白质与谷物的秩序组合，适合“明天要自律”的你。',
    category: MenuCategory.healthy,
  ),
  MenuItem(
    id: 'sandwich',
    name: '三明治/贝果',
    description: '轻装上阵。简单但不失体面，适合边走边吃的任务。',
    category: MenuCategory.healthy,
  ),
  MenuItem(
    id: 'soup',
    name: '汤/炖菜',
    description: '温暖的回复道具。对“又冷又累”的 debuff 有奇效。',
    category: MenuCategory.healthy,
  ),

  // Noodles
  MenuItem(
    id: 'lanzhou',
    name: '兰州拉面',
    description: '东方的神秘面条。清汤中蕴含着匠人的灵魂，牛肉只是点缀。',
    category: MenuCategory.noodles,
  ),
  MenuItem(
    id: 'cq_noodles',
    name: '重庆小面',
    description: '麻辣的试炼。红油与花椒的交响曲，挑战你的味蕾极限。',
    category: MenuCategory.noodles,
  ),
  MenuItem(
    id: 'luosifen',
    name: '螺蛳粉',
    description: '嗅觉的震撼弹。爱之者奉为神明，恨之者避之不及的混沌料理。',
    category: MenuCategory.noodles,
  ),
  MenuItem(
    id: 'udon',
    name: '乌冬/日式面',
    description: '稳健的选择。清爽但不寡淡，属于“不会踩雷”的那一类。',
    category: MenuCategory.noodles,
  ),
  MenuItem(
    id: 'pasta',
    name: '意面/番茄肉酱',
    description: '西式的安全牌。番茄与香料，适合需要一点“异世界感”的中午。',
    category: MenuCategory.noodles,
  ),
  MenuItem(
    id: 'knife_noodles',
    name: '刀削面/面馆',
    description: '硬核手艺活。面条的口感像是角色的“耐力值”在增长。',
    category: MenuCategory.noodles,
  ),

  // Rice
  MenuItem(
    id: 'shaxian',
    name: '沙县小吃',
    description: '街角的守护者。无论何时何地，它都在那里等待着饥饿的旅人。',
    category: MenuCategory.rice,
  ),
  MenuItem(
    id: 'curry',
    name: '卢布朗咖喱',
    description: '老板佐仓惣治郎的自信之作。辛辣中带着成熟的余韵，回复所有SP。',
    category: MenuCategory.rice,
  ),
  MenuItem(
    id: 'longjiang',
    name: '隆江猪脚饭',
    description: '男人的浪漫。软糯的猪脚与浓郁的卤汁，是打工人的灵魂慰藉。',
    category: MenuCategory.rice,
  ),
  MenuItem(
    id: 'hmc',
    name: '黄焖鸡米饭',
    description: '重装坦克。浓稠的酱汁带来扎实的满足感，但请小心“困意”。',
    category: MenuCategory.rice,
  ),
  MenuItem(
    id: 'bbq_rice',
    name: '烤肉饭/照烧鸡',
    description: '甜咸的平衡。适合对“今天不想思考”的你。',
    category: MenuCategory.rice,
  ),
  MenuItem(
    id: 'bento',
    name: '便当/食堂套餐',
    description: '日常的秩序。也许平凡，但能稳定推进主线进度。',
    category: MenuCategory.rice,
  ),

  // Chaos
  MenuItem(
    id: 'malatang',
    name: '麻辣烫',
    description: '万物的熔炉。将一切食材投入沸腾的汤底，诞生出未知的美味。',
    category: MenuCategory.random,
  ),
  MenuItem(
    id: 'random_delivery',
    name: '外卖随缘',
    description: '命运的轮盘赌。打开外卖软件，闭眼点击，接受命运的安排。',
    category: MenuCategory.random,
  ),
  MenuItem(
    id: 'convenience',
    name: '便利店补给',
    description: '补给站。饭团/关东煮/盒饭，快速恢复少量 HP，节约时间。',
    category: MenuCategory.random,
  ),
  MenuItem(
    id: 'new_shop',
    name: '随机新店',
    description: '探索模式。打开地图，选一家没吃过的店，可能触发“隐藏支线”。',
    category: MenuCategory.random,
  ),
];
