//
//  RuntimeStatus.m
//  LittleKid
//
//  Created by 李允恺 on 12/19/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import "RuntimeStatus.h"

@implementation UserInfo
- (instancetype)init
{
    self = [super init];
    if (self) {
        //TODO
        self.score = @0;
    }
    return self;
}
@end

@implementation RuntimeStatus

+ (instancetype)instance
{
    static RuntimeStatus* g_runtimeState;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_runtimeState = [[RuntimeStatus alloc] init];
        
    });
    return g_runtimeState;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.usrSelf = [[UserSelf alloc] init];
        self.recentUsrList = [[NSMutableArray alloc] init];
        self.signAccountUID = [[NSString alloc] init];
        self.httpClient = [[HTTTClient alloc] init];
        self.udpP2P = [[UDPP2P alloc] init];
        self.userInfo = [[UserInfo alloc] init];
        self.friends = [NSMutableArray array];
    }
    return self;
}


- (void) initial {
    [self initialDb];
    
    self.currentUser = [AVUser currentUser];
    
    AVObject* userInfo = [self.currentUser objectForKey:@"userInfo"];
    [userInfo fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        if (error) {
            NSLog(@"fetch user info error: %@", error);
        }
        else {
            NSData *headImage = [object objectForKey:@"headImage"];
            self.userInfo.headImage = [self circleImage:[UIImage imageWithData:headImage] withParam:0];
            self.userInfo.nickname = [userInfo objectForKey:@"nickname"];
            self.userInfo.birthday = [userInfo objectForKey:@"birthday"];
            self.userInfo.gender = [userInfo objectForKey:@"gender"];
            self.userInfo.level = [userInfo objectForKey:@"level"];
            self.userInfo.score = [userInfo objectForKey:@"score"];
        }
    }];
    
    [self.currentUser getFollowees:^(NSArray *objects, NSError *error) {
        [self updateLoaclFriendList:objects];
    }];
    
    //TODO
    self.friendsToBeConfirm = [NSMutableArray array];
}


- (void) updateLoaclFriendList: (NSArray *)friends {
    //TODO: 暂时未考虑好友删除的情况
    
    //update local friend info
    for (UserInfo *userInfo in self.friends) {
        [friends enumerateObjectsUsingBlock:^(AVUser *obj, NSUInteger idx, BOOL *stop) {
            if ([userInfo.objID isEqualToString:obj.objectId]) {
                *stop = YES;
                
                AVObject *u = [obj objectForKey:@"userInfo"];
                [u fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                    NSDate *updatedAt = object.updatedAt;
                    if ([updatedAt laterDate:userInfo.updatedAt]) {
                        userInfo.updatedAt = updatedAt;
                        
                        NSData *headImage = [object objectForKey:@"headImage"];
                        userInfo.headImage = [UIImage imageWithData:headImage];
                        userInfo.nickname = [object objectForKey:@"nickname"];
                        userInfo.birthday = [object objectForKey:@"birthday"];
                        userInfo.gender = [object objectForKey:@"gender"];
                        userInfo.level = [object objectForKey:@"level"];
                        userInfo.score = [object objectForKey:@"score"];
                        
                        [self updateLocalFriend:object byObjId:u.objectId];
                    }
                }];
            }
        }];
    }
    
    //add new friend info
    for (AVUser* friend in friends) {
        __block BOOL found = NO;
        [self.friends enumerateObjectsUsingBlock:^(UserInfo *obj, NSUInteger idx, BOOL *stop) {
            if ([obj.objID isEqualToString:friend.objectId]) {
                *stop = YES;
                found = YES;
            }
        }];
        if (!found) {
            UserInfo *user = [[UserInfo alloc] init];
            user.objID = friend.objectId;
            user.userName = friend.username;
            
//            [friend fetch];
            
            AVObject *userInfo = [friend objectForKey:@"userInfo"];
            [userInfo fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                if (error) {
                    NSLog(@"fetch userInfo error");
                }
                else
                {
                    user.nickname = [object objectForKey:@"nickname"];
                    user.birthday = [object objectForKey:@"birthday"];
                    
                    user.nickname = [object objectForKey:@"nickname"];
                    user.birthday = [object objectForKey:@"birthday"];
                    user.gender = [object objectForKey:@"gender"];
                    user.level = [object objectForKey:@"level"];
                    user.score = [object objectForKey:@"score"];
                    
                    NSData *headImage = [object objectForKey:@"headImage"];
                    user.headImage = [UIImage imageWithData:headImage];
                    
                    user.updatedAt = object.updatedAt;
                    
                    [self updateLocalFriend:user byObjId:friend.objectId];
                    NSLog(@"fetch userInfo succes");
                    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_GET_FRIEND_LIST object:nil userInfo:nil];
                }

            }];
            
            [self.friends addObject:user];
            [self addLocalFriend:friend];
        }
    }
}

- (void) updateLocalFriend: (UserInfo *)userInfo byObjId: (NSString*)friendObjID {
    //TODO: complete all the update
    [self.db executeUpdateWithFormat:@"UPDATE friends SET nickname = %@, birthday = %@, updatedAt = %@ WHERE selfId = %@ and friendId = %@",
     userInfo.nickname,
     userInfo.birthday,
     userInfo.updatedAt,
     [AVUser currentUser].objectId,
     friendObjID];
}

- (void) addLocalFriend: (AVUser*) user {
    [self.db executeUpdateWithFormat:@"INSERT INTO friends (selfId, friendId, friendName) VALUES(%@, %@, %@)", [AVUser currentUser].username, user.objectId, user.username];
}


- (void) initialDb {
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbFileName =[dbPath stringByAppendingPathComponent:@"LittleKid.sqlite"];
    
    self.db = [FMDatabase databaseWithPath:dbFileName];
    
    if (![self.db open]) {
        NSLog(@"local database open error!");
        return;
    }
    
    //create the friend table if not exists
    BOOL result = [self.db executeUpdateWithFormat:@"CREATE TABLE IF NOT EXISTS friends (selfId text NOT NULL, friendId text NOT NULL, friendName text NOT NULL, nickname text, birthday text, gender text, level integer default 0, score integer default 0, headImage blob, updatedAt text);"];
    
    if (!result) {
        NSLog(@"Create table friends error!");
        return;
    }
    
    //get all the friend user info
    FMResultSet *resultSet = [self.db executeQueryWithFormat:@"select friendId, friendName, nickname, birthday, gender, level, score, headImage, updatedAt from friends where selfId = %@",
                              [AVUser currentUser].objectId];
    
    while ([resultSet next]) {
        UserInfo *userInfo = [[UserInfo alloc] init];
        userInfo.objID = [resultSet stringForColumn:@"friendId"];
        userInfo.userName = [resultSet stringForColumn:@"friendName"];
        userInfo.nickname = [resultSet stringForColumn:@"nickname"];
        userInfo.birthday = [resultSet dateForColumn:@"birthday"];
        userInfo.gender = [resultSet stringForColumn:@"gender"];
        userInfo.level = [NSNumber numberWithInt:[resultSet intForColumn:@"level"]];
        userInfo.score = [NSNumber numberWithInt:[resultSet intForColumn:@"score"]];
        userInfo.headImage = [UIImage imageWithData:[resultSet dataForColumn:@"headImage"]];
        userInfo.updatedAt = [resultSet dateForColumn:@"updatedAt"];
        
        [self.friends addObject:userInfo];
    }
}
-(UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset {
    
    UIGraphicsBeginImageContext(image.size);
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    //圆的边框宽度为2，颜色为红色
    
    CGContextSetLineWidth(context,2);
    
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    CGRect rect = CGRectMake(inset, inset, image.size.width - inset *2.0f, image.size.height - inset *2.0f);
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextClip(context);
    
    //在圆区域内画出image原图
    
    [image drawInRect:rect];
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextStrokePath(context);
    
    //生成新的image
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newimg;
    
}
-(NSString *)getLevelString:(NSNumber *)number//0-12
{
    NSInteger i = number.integerValue;
    i = i/10000;
    switch (i) {
        case 0:
            return @"九级棋士";
        case 1:
            return @"八级棋士";
        case 2:
            return @"七级棋士";
        case 3:
            return @"六级棋士";
        case 4:
            return @"五级棋士";
        case 5:
            return @"四级棋士";
        case 6:
            return @"三级棋士";
        case 7:
            return @"二级棋士";
        case 8:
            return @"一级棋士";
        case 9:
            return @"三级大师";
        case 10:
            return @"二级大师";
        case 11:
            return @"一级大师";
        case 12:
            return @"特级大师";
        default:
            return nil;
    }
}

- (void) saveUserInfo {
    AVObject* userInfo = [self.currentUser objectForKey:@"userInfo"];
    [userInfo setObject:UIImageJPEGRepresentation(self.userInfo.headImage, 1.0) forKey:@"headImage"];
    [userInfo setObject:self.userInfo.nickname forKey:@"nickname"];
    [userInfo setObject:self.userInfo.birthday forKey:@"birthday"];
    [userInfo setObject:(self.userInfo.gender) forKey:@"gender"];
    [userInfo setObject:(self.userInfo.score) forKey:@"score"];
    //TODO
    
//    [self.currentUser saveInBackground];
    [userInfo saveInBackground];
}

- (void) setNickName:(NSString *)nickname {
    self.userInfo.nickname = nickname;
//    [self saveUserInfo];
}

- (void) setBirthday:(NSDate *)birthday {
    self.userInfo.birthday = birthday;
//    [self saveUserInfo];
}

- (void) setHeadImage:(UIImage *)image {
    self.userInfo.headImage = image;
//    [self saveUserInfo];
}

- (UserInfo*)getFriendUserInfo:(NSString *)userName {
    __block UserInfo *userInfo;
    [self.friends enumerateObjectsUsingBlock:^(UserInfo *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.userName isEqualToString:userName]) {
            *stop = YES;
            userInfo = [self.friends objectAtIndex:idx];
            return;
        }
    }];
    
    return userInfo;
}

- (void) addFriendsToBeConfirm:(NSString *)oneFriend {
    AVQuery * query = [AVUser query];
    [query whereKey:@"username" equalTo:oneFriend];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil) {
            AVUser  *peerUser = [objects firstObject];
            
            if (peerUser == nil) {
                //TODO
                return;
            }
            UserInfo *user = [[UserInfo alloc] init];
            user.objID = peerUser.objectId;
            user.userName = peerUser.username;
            AVObject *userInfo = [peerUser objectForKey:@"userInfo"];
            [userInfo fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                if (error) {
                    NSLog(@"fetch tobeConfirmuserInfo error");
                }
                else
                {
                    user.nickname = [object objectForKey:@"nickname"];
                    user.birthday = [object objectForKey:@"birthday"];
                    
                    user.nickname = [object objectForKey:@"nickname"];
                    user.birthday = [object objectForKey:@"birthday"];
                    user.gender = [object objectForKey:@"gender"];
                    user.level = [object objectForKey:@"level"];
                    user.score = [object objectForKey:@"score"];
                    
                    NSData *headImage = [object objectForKey:@"headImage"];
                    user.headImage = [UIImage imageWithData:headImage];
                    
                    user.updatedAt = object.updatedAt;
                    NSLog(@"fetch tobeConfirmuserInfo succes");
                    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_GET_FRIEND_LIST object:nil userInfo:nil];
                }
                
            }];
            
            [self.friendsToBeConfirm addObject:user];
            ;
        } else {
            
        }
    }];
    
}
- (void)removeFriendsToBeConfirm:(NSString *)oneFriend
{
    [self.friendsToBeConfirm enumerateObjectsUsingBlock:^(UserInfo *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.userName isEqualToString:oneFriend]) {
            *stop = YES;
            [self.friendsToBeConfirm removeObject:obj];
            return;
        }
    }];
}


- (void)loadLocalInfo{
    self.usrSelf = [[UserSelf alloc] initWithUID:self.signAccountUID];
    [self loadLocalRecent];
    
}

- (void)testCode{
    //self.usrSelf.UID = @"0000";
    self.usrSelf.nickName = @"自己";
    self.usrSelf.headPicture = @"head.jpg";
    self.usrSelf.signature = @"小钱长老了老钱";
    self.usrSelf.address = @"启明704";
    self.usrSelf.birthday = @"20";
    self.usrSelf.gender = @"男";
    self.usrSelf.state = @"1";
    if(self.usrSelf.friends == nil){
        self.usrSelf.friends = [[NSMutableArray alloc] init];
    }
    UserOther *friend = [[UserOther alloc] init];
    friend.UID = @"15926305768";
    friend.nickName = @"第二个朋友";
    friend.headPicture = @"head.jpg";
    friend.signature = @"相信男神";
    friend.address = @"启明704";
    friend.birthday = @"22";
    friend.gender = @"男";
    friend.state = @"1";
    friend.usrIP = @"192.168.3.1";
    friend.usrPort = @"20107";
    ChatMessage *msg = [[ChatMessage alloc] init];
    msg.ownerUID = @"15926305768";
    msg.type = @"whatever";
    msg.msg = @"do it or not?";
    msg.timeStamp = @"时间先用string类型";
    friend.msgs = [[NSMutableArray alloc] init];
    [friend.msgs addObject:msg];
    [self.usrSelf.friends addObject:friend];
    friend.nickName = @"吴相鑫";
    [self.usrSelf.friends addObject:friend];
    [self.recentUsrList addObject:friend];
    friend.UID = @"13164696487";
    friend.nickName = @"自己";
    friend.usrIP = @"127.0.0.1";
    friend.usrPort = @"20107";
    [self.recentUsrList addObject:friend];
    //save
    [self.usrSelf save];
    for (UserOther *recent1Usr in self.recentUsrList) {
        [recent1Usr save];
    }
}

/* must called after load the usrself */
- (NSString *)recentDir{
    return [NSString stringWithFormat:@"%@/%@/recent", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], self.usrSelf.UID];
}

- (void)loadLocalRecent{
    NSError *err;
    NSString *recentUsrsRootPath = [self recentDir];
    NSArray *recentUsrsPathArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:recentUsrsRootPath error:&err];
    if (err) {
        [self testCode];
        return;
    }
    if ( [recentUsrsPathArr count] == 0 ) {// decide if it's an empty array
        return;
    }
    UserOther *recent1Usr;
    for (NSString *recentUsrPath in recentUsrsPathArr) {
        if ([recentUsrPath containsString:@".xcui"]) {
            recent1Usr = [[UserOther alloc] initWithPath:[recentUsrsRootPath stringByAppendingPathComponent:recentUsrPath]];
            if (recent1Usr) {
                [self.recentUsrList addObject:recent1Usr];
            }
            recent1Usr = nil;
        }
    }
}

- (void)procNewP2PChatMsg:(NSDictionary *)newChatMsgDict{
    ChatMessage *newMsg = [NSKeyedUnarchiver unarchiveObjectWithData:[newChatMsgDict objectForKey:CHATMSG_KEY_CHATMSG]];
    for (UserOther *recent1Usr in self.recentUsrList) {
        if ([recent1Usr.UID compare:newMsg.ownerUID]) {
            [recent1Usr procNewChatMsgWithDict:newChatMsgDict];
            return;
        }
    }
    //陌生消息处理
    //new msg for new recentUsr
    UserOther *newRecentUser = [[UserOther alloc] init];
    //首先对该用户的UID赋值
    newRecentUser.UID = [NSString stringWithFormat:@"%@",newMsg.ownerUID];
    [newRecentUser procNewChatMsgWithDict:newChatMsgDict];
    //将新用户加入列表
    [self.recentUsrList addObject:newRecentUser];
}


- (void)loadServerRecentMsg:(NSArray *)serverRecentMsgList{
    if(serverRecentMsgList == nil){
        return;
    }
    if ([serverRecentMsgList count]==0) {
        return;
    }
    for (NSDictionary *recent1MsgDict in serverRecentMsgList) {
        //do something
        NSString *msgOwnerUID = [NSString stringWithFormat:@"%@",[recent1MsgDict objectForKey:CHATMSG_KEY_OWNER_UID]];
        BOOL msgPorcedFlag = NO;
        for (UserOther *recent1Usr in self.recentUsrList) {
            if ([recent1Usr.UID compare:msgOwnerUID]) {
                //the user do proc the msg
                [recent1Usr procServerNewChatMsgWithDict:recent1MsgDict];
                //proc end
                msgPorcedFlag = YES;
                break;
            }
        }
        if (msgPorcedFlag == YES) {
            continue;
        }
        //陌生消息处理
        //new msg for new recentUsr
        UserOther *newRecentUser = [[UserOther alloc] init];
        //首先对新用户UID赋值操作
        newRecentUser.UID = [NSString stringWithFormat:@"%@",[recent1MsgDict objectForKey:CHATMSG_KEY_OWNER_UID]];
        [newRecentUser procServerNewChatMsgWithDict:recent1MsgDict];
        //将新用户加入列表
        [self.recentUsrList addObject:newRecentUser];
    }
}




@end
