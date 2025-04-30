// import 'package:dojodex_common/models/club/club.dart';
// import 'package:dojodex_common/models/message/message.dart';
// import 'package:dojodex_common/models/message/message_from.dart';
// import 'package:dojodex_common/models/user/user.dart';
// import 'package:dojodex_instructor/blocs/authentication/authentication_bloc.dart';
// import 'package:dojodex_instructor/blocs/club/club_bloc.dart';
// import 'package:dojodex_instructor/blocs/message/message_bloc.dart';
// import 'package:dojodex_instructor/common/routes/route_helper.dart';
// import 'package:dojodex_instructor/common/services/user_service.dart';
// import 'package:dojodex_instructor/common/widgets/headers.dart';
// import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
// import 'package:dojodex_instructor/features/chat/chat_screen_old.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:dojodex_common/ui/ui.dart';
// import 'package:dojodex_common/extensions/text_extension.dart';
// import 'package:logger/web.dart';
// import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

// class MessagingScreen extends StatefulWidget {
//   const MessagingScreen({super.key});

//   @override
//   State<MessagingScreen> createState() => _MessagingScreenState();
// }

// class _MessagingScreenState extends State<MessagingScreen> {
//   late RefreshController _refreshController;
//   late bool isRefreshing;
//   @override
//   void initState() {
//     isRefreshing = false;
//     context.read<ClubBloc>().add(const FetchClubs());
//     context.read<MessageBloc>().add(const FetchAllMessages());

//     _refreshController = RefreshController();

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: DojoDexHeaders.mainAppBar(),
//       body: SmartRefresher(
//         controller: _refreshController,
//         header: const WaterDropHeader(),
//         enablePullDown: true,
//         onRefresh: _onRefresh,
//         onLoading: _onLoading,
//         child: ColoredBox(
//           color: DojoDexColors.white,
//           child: Column(
//             children: [
//               DojoDexHeaders.mainHeader(
//                 title: _buildHeaderAndRefreshButton(context),
//               ),
//               _buildSearchPeople(context),
//               _buildChatLists(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Expanded _buildChatLists() {
//     return Expanded(
//       child: BlocBuilder<ClubBloc, ClubState>(
//         builder: (context, clubState) {
//           final clubIds = clubState.clubs?.map((e) => e.id.toString()).toList();
//           return BlocConsumer<MessageBloc, MessageState>(
//             listenWhen: (previous, current) =>
//                 previous.isLoading != current.isLoading,
//             listener: (context, state) {
//               sl<Logger>().i(state.isLoading);
//               if ((state.isLoading ?? false)) {
//                 _refreshController.requestRefresh();
//               }
//               if (!(state.isLoading ?? false)) {
//                 setState(() {
//                   isRefreshing = false;
//                 });
//                 _refreshController.refreshCompleted();
//               }
//             },
//             buildWhen: (previous, current) =>
//                 previous.messages != current.messages,
//             builder: (context, messageState) {
//               /// Given that I have this structure, I would refactor the code using [state.groupMessages()]
//               final messages = messageState.groupMessages(clubIds ?? []);
//               sl<Logger>().i(messages);

//               /// I would then use the [messages] to build the list
//               /// Every data should call the getLatestMessage() method to get the latest message
//               /// I would then use the [getLatestMessage] to build the list

//               return ListView.builder(
//                 itemCount: messages.length,
//                 itemBuilder: (context, index) {
//                   final message = messages.values.elementAt(index);
//                   final messageKey = messages.keys.elementAt(index);
//                   final latestMessage = messageState.getLatestMessage(
//                     messageKey,
//                     message,
//                   );

//                   if (latestMessage is DirectMessage) {
//                     return BlocBuilder<AuthenticationBloc, AuthenticationState>(
//                       builder: (context, authenticationState) {
//                         final otherUser = messageState.getOtherUser(
//                             messageKey,
//                             int.parse(authenticationState.user?.id.toString() ??
//                                 '0'));
//                         return _buildDirectMessage(
//                           latestMessage,
//                           context,
//                           messageKey,
//                           otherUser,
//                         );
//                       },
//                     );
//                   }
//                   if (latestMessage is ClubMessage) {
//                     return _buildClubMessage(
//                       latestMessage,
//                       context,
//                       messageKey: messageKey,
//                       clubState: clubState,
//                     );
//                   }
//                   if (latestMessage is AnnouncementMessage) {
//                     return _buildAnnouncementMessage(
//                       latestMessage,
//                       context,
//                       messageKey,
//                     );
//                   }
//                   return _buildClubMessage(
//                     ClubMessage(
//                       // message:
//                       //     'No conversations available. Begin a discussion to display announcements.',
//                       message: '',
//                       messageFromClub: messageKey,
//                     ),
//                     context,
//                     messageKey: messageKey,
//                     clubState: clubState,
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   InkWell _buildSearchPeople(BuildContext context) {
//     return InkWell(
//       onTap: () async {
//         final user = await sl<RouteHelper>().showUserSearchScreen();
//         if (user == null) {
//           return;
//         }
//         final currentUser = await sl<UserService>().getUser();
//         // ignore: use_build_context_synchronously
//         final mapKey = context
//             .read<MessageBloc>()
//             .state
//             .getConversationKey(user.id, currentUser?.id ?? 0);
//         sl<RouteHelper>().showChatScreen(ChatArguments(
//           userToChat: user,
//           message: DirectMessage(
//             messageTo: MessageUser(
//               userId: user.id,
//               name: user.name,
//             ),
//           ),
//           key: mapKey,
//         ));
//       },
//       child: IgnorePointer(
//         ignoring: true,
//         child: CustomSearchView(
//           hintText: 'Search people',
//           onChanged: (value) {},
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderAndRefreshButton(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           "Messages",
//           style: context.textTheme.headlineMedium?.copyWith(),
//         ),

//         /// refresh button
//         !isRefreshing
//             ? IconButton(
//                 icon: const Icon(Icons.refresh),
//                 onPressed: () {
//                   _refreshController.requestRefresh();
//                 },
//               )
//             : const SizedBox(),
//       ],
//     );
//   }

//   void _onRefresh() async {
//     setState(() {
//       isRefreshing = true;
//     });
//     context.read<ClubBloc>().add(const FetchClubs());
//     context.read<MessageBloc>().add(const FetchAllMessages());
//   }

//   void _onLoading() async {
//     _refreshController.loadComplete();
//   }

//   Widget _buildAnnouncementMessage(
//     AnnouncementMessage message,
//     BuildContext context,
//     String? messageKey,
//   ) {
//     return _buildMessageTile(
//       'DojoDex',
//       null,
//       message,
//       avatar: const CircleAvatar(
//         radius: 25,
//         backgroundColor: DojoDexColors.gray5,
//         child: Icon(
//           Icons.notifications,
//           color: DojoDexColors.white,
//         ),
//       ),
//       onTap: () {
//         final arguments = ChatArguments(
//           userToChat: User(
//             id: int.parse(message.messageFromClub ?? '0'),
//             name: "DojoDex",
//           ),
//           message: message,
//           key: messageKey,
//         );
//         sl<RouteHelper>().showChatScreen(
//           arguments,
//         );
//       },
//     );
//   }

//   Widget _buildClubMessage(
//     ClubMessage message,
//     BuildContext context, {
//     String? messageKey,
//     ClubState? clubState,
//   }) {
//     return Builder(builder: (context) {
//       final Club? club = clubState?.clubs?.firstWhere(
//         (element) {
//           return element.id.toString() == message.messageFromClub.toString();
//         },
//         orElse: () => const Club(),
//       );

//       if (club?.id == null) {
//         sl<Logger>().i({'Club not found', message.messageFrom?.name});
//         return const SizedBox();
//       }

//       final chatName = club?.title ?? message.messageFrom?.name ?? '';
//       Widget? avatar;
//       if (club?.imageurl == '') {
//         avatar = const CircleAvatar(
//           radius: 25,
//           backgroundColor: DojoDexColors.gray5,
//           child: Icon(
//             Icons.group_work_rounded,
//             color: DojoDexColors.white,
//           ),
//         );
//       }

//       return _buildMessageTile(
//         chatName,
//         club?.imageurl,
//         message,
//         avatar: avatar,
//         onTap: () {
//           final arguments = ChatArguments(
//             userToChat: User(
//               id: int.parse(message.messageFromClub ?? '0'),
//               name: chatName,
//             ),
//             message: message,
//             key: messageKey,
//           );
//           sl<RouteHelper>().showChatScreen(
//             arguments,
//           );
//         },
//       );
//     });
//   }

//   ListTile _buildMessageTile(
//     String title,
//     String? avatarUrl,
//     Message message, {
//     Widget? avatar,
//     String? key,
//     Function()? onTap,
//   }) {
//     return ListTile(
//       onTap: onTap,
//       title: Row(
//         children: [
//           avatar ??
//               ProfileImage(
//                 profileImage: avatarUrl,
//                 size: 25,
//               ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: context.textTheme.bodyMedium!.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                 ),
//                 const SizedBox(height: 4),
//                 Builder(builder: (context) {
//                   if (message is AnnouncementMessage) {
//                     return Text(
//                       message.message ?? '',
//                       style: context.textTheme.bodySmall,
//                     );
//                   }
//                   return Text(
//                     message.message ?? '',
//                     style: context.textTheme.bodySmall,
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 2,
//                   );
//                 }),
//               ],
//             ),
//           ),
//           const SizedBox(width: 8),
//           const Icon(
//             Icons.arrow_forward_ios,
//             size: 16,
//             color: DojoDexColors.gray4,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDirectMessage(
//     DirectMessage message,
//     BuildContext context,
//     String messageKey,
//     MessageUser? otherUser,
//   ) {
//     return _buildMessageTile(
//       otherUser?.name ?? '',
//       null,
//       message,
//       key: messageKey,
//       onTap: () {
//         final arguments = ChatArguments(
//           userToChat: User(
//             id: otherUser?.userId,
//             name: otherUser?.name,
//           ),
//           message: message.copyWith(
//             messageTo: MessageUser(
//               userId: otherUser?.userId,
//               name: otherUser?.name,
//             ),
//           ),
//           key: messageKey,
//         );
//         sl<RouteHelper>().showChatScreen(
//           arguments,
//         );
//       },
//     );
//   }
// }
