import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../domain/entities/entities.dart';
import '../providers/chat_provider.dart';
import '../widgets/widgets.dart';

/// The main conversations list page.
///
/// Features:
/// - Tab bar for filtering: All, Direct, Groups
/// - FAB to start a new conversation
/// - List of conversations sorted by last activity
/// - Real-time updates for new messages
/// - Unread badges
class ConversationsPage extends ConsumerStatefulWidget {
  /// Creates a [ConversationsPage] widget.
  const ConversationsPage({super.key});

  @override
  ConsumerState<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends ConsumerState<ConversationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    // Refresh data when page opens to prevent stale data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationsNotifierProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final filter = ConversationFilter.values[_tabController.index];
      ref.read(conversationFilterNotifierProvider.notifier).setFilter(filter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final conversationsAsync = ref.watch(conversationsNotifierProvider);
    final currentFilter = ref.watch(conversationFilterNotifierProvider);

    return Scaffold(
      body: Container(
        decoration: isPlayful
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.03),
                    theme.colorScheme.secondary.withValues(alpha: 0.03),
                    theme.colorScheme.tertiary.withValues(alpha: 0.03),
                  ],
                ),
              )
            : null,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                backgroundColor: isPlayful
                    ? theme.colorScheme.surface.withValues(alpha: 0.95)
                    : theme.colorScheme.surface,
                elevation: isPlayful ? 0 : 1,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(left: AppSpacing.md, bottom: 50),
                  title: Text(
                    'Messages',
                    style: TextStyle(
                      fontSize: isPlayful ? 24 : 22,
                      fontWeight: isPlayful ? FontWeight.w800 : FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: isPlayful ? 0.3 : -0.3,
                    ),
                  ),
                  background: isPlayful
                      ? Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                theme.colorScheme.primary.withValues(alpha: 0.08),
                                theme.colorScheme.surface.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        )
                      : null,
                ),
                bottom: TabBar(
                  controller: _tabController,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor:
                      theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  labelStyle: TextStyle(
                    fontSize: isPlayful ? 15 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: isPlayful ? 15 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                  indicatorColor: theme.colorScheme.primary,
                  indicatorWeight: isPlayful ? 3 : 2,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Direct'),
                    Tab(text: 'Groups'),
                  ],
                ),
              ),
            ];
          },
          body: RefreshIndicator(
            onRefresh: () async {
              await ref.read(conversationsNotifierProvider.notifier).refresh();
            },
            child: conversationsAsync.when(
              data: (allConversations) {
                final conversations = ref.watch(
                  filteredConversationsProvider(currentFilter),
                );

                if (conversations.isEmpty) {
                  return _buildEmptyState(theme, isPlayful, currentFilter);
                }

                return ResponsiveCenterScrollView(
                  maxWidth: 800,
                  padding: EdgeInsets.symmetric(
                    horizontal: isPlayful ? AppSpacing.sm : AppSpacing.xs,
                    vertical: isPlayful ? AppSpacing.xs : AppSpacing.xxs,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      ...conversations.map((conversation) => Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: isPlayful ? AppSpacing.xxs : 2,
                            ),
                            child: ConversationTile(
                              conversation: conversation,
                              onTap: () => _openConversation(conversation),
                            ),
                          )),
                      SizedBox(height: AppSpacing.xxxl * 2),
                    ],
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => _buildErrorState(
                theme,
                isPlayful,
                error.toString(),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewConversation,
        backgroundColor: isPlayful
            ? theme.colorScheme.primary
            : theme.colorScheme.primaryContainer,
        foregroundColor: isPlayful
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onPrimaryContainer,
        elevation: isPlayful ? 6 : 3,
        child: Icon(
          Icons.edit_rounded,
          size: isPlayful ? 26 : 24,
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    ThemeData theme,
    bool isPlayful,
    ConversationFilter filter,
  ) {
    String title;
    String subtitle;
    IconData icon;

    switch (filter) {
      case ConversationFilter.all:
        title = 'No conversations yet';
        subtitle = 'Start a conversation by tapping the button below';
        icon = Icons.chat_bubble_outline_rounded;
        break;
      case ConversationFilter.direct:
        title = 'No direct messages';
        subtitle = 'Your direct conversations will appear here';
        icon = Icons.person_outline_rounded;
        break;
      case ConversationFilter.groups:
        title = 'No group chats';
        subtitle = 'Create or join a group to start chatting';
        icon = Icons.group_outlined;
        break;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isPlayful ? 28 : AppSpacing.xl),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                icon,
                size: isPlayful ? 64 : 56,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: isPlayful ? 28 : AppSpacing.xl),
            Text(
              title,
              style: TextStyle(
                fontSize: isPlayful ? 22 : 20,
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
                letterSpacing: isPlayful ? 0.3 : 0,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isPlayful ? 15 : 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, bool isPlayful, String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: isPlayful ? 72 : 64,
              color: theme.colorScheme.error.withValues(alpha: 0.6),
            ),
            SizedBox(height: isPlayful ? AppSpacing.xl : AppSpacing.lg),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: isPlayful ? 20 : 18,
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(conversationsNotifierProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _openConversation(ConversationEntity conversation) {
    ref.read(selectedConversationProvider.notifier).select(conversation);
    context.push('/chat/${conversation.id}?isGroup=${conversation.isGroup}');
  }

  void _startNewConversation() {
    context.push('/chat/new');
  }
}
