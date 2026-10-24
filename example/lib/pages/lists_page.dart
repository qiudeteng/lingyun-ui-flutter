import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:lingyun_ui_flutter/lingyun_ui_flutter.dart';

/// 内嵌分组与通栏 [GlassList]。可见文案为简体中文。
class ListsPage extends StatelessWidget {
  const ListsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = LingyunTheme.colorsOf(context).liquidGlassLabels.primary;
    return ListView(
      padding: LingyunLayout.layoutMarginOf(context),
      children: [
        Text(
          '列表',
          key: const Key('lists-title'),
          style: LingyunTextStyles.largeTitle(emphasized: true, color: primary),
        ),
        const SizedBox(height: 8),
        Text(
          '内嵌分组的每一节共用一块液态玻璃托盘，尺寸为常规中号。'
          '通栏列表只有分隔线，没有托盘。'
          '标题使用主标签色：浅色 #1A1A1A，深色 #EDEDED。'
          '副标题、右侧数值和分隔线使用三级标签色：浅色 #BFBFBF，深色 #404040。'
          '托盘不是厚材质。',
          style: LingyunTextStyles.body(color: primary),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final inset = _inset();
            final plain = _plain();
            if (constraints.maxWidth < 760) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [inset, const SizedBox(height: 28), plain],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: inset),
                const SizedBox(width: 28),
                Expanded(child: plain),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _inset() {
    return const GlassList(
      key: Key('lists-inset'),
      sections: [
        GlassListSection(
          header: '连接',
          footer: '已知网络只保存在这台设备上。',
          tiles: [
            GlassListTile(
              title: '无线局域网',
              subtitle: '家',
              trailingText: '开',
              showChevron: true,
              leading: Icon(CupertinoIcons.wifi),
            ),
            GlassListTile(
              title: '蓝牙',
              subtitle: '关',
              showChevron: true,
              leading: Icon(CupertinoIcons.bluetooth),
            ),
            GlassListTile(
              title: '蜂窝网络',
              trailingText: '5G',
              showChevron: true,
              leading: Icon(CupertinoIcons.antenna_radiowaves_left_right),
            ),
          ],
        ),
        GlassListSection(
          header: '通用',
          tiles: [
            GlassListTile(
              title: '关于本机',
              showChevron: true,
              leading: Icon(CupertinoIcons.info),
            ),
            GlassListTile(
              title: '软件更新',
              subtitle: '1 项更新',
              showChevron: true,
              leading: Icon(CupertinoIcons.gear),
            ),
          ],
        ),
      ],
    );
  }

  Widget _plain() {
    return const GlassList(
      key: Key('lists-plain'),
      style: GlassListStyle.plain,
      sections: [
        GlassListSection(
          header: '最近',
          tiles: [
            GlassListTile(
              title: '设计评审',
              subtitle: '昨天',
              trailingText: '凌云',
              leading: Icon(CupertinoIcons.doc_text),
            ),
            GlassListTile(
              title: '截图检查',
              subtitle: '已就绪',
              trailingText: '今天',
              leading: Icon(CupertinoIcons.photo),
            ),
            GlassListTile(title: '备忘录', trailingText: '3', showChevron: true),
          ],
        ),
      ],
    );
  }
}
