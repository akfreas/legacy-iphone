#include "PageProtocol.h"

#define AKDictionaryOfVariableBindings(...) _AKDictionaryOfVariableBindings(@"" # __VA_ARGS__, __VA_ARGS__, nil)
NSDictionary * _AKDictionaryOfVariableBindings(NSString *commaSeparatedKeysString, id firstValue, ...);

@interface LegacyInfoPage : UIView <PageProtocol>

@end
