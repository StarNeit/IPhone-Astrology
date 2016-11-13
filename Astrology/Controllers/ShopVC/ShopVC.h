
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface ShopVC : UIViewController<SKProductsRequestDelegate,SKPaymentTransactionObserver>{

}

- (void)fetchAvailableProducts;
- (BOOL)canMakePurchases;
- (void)purchaseMyProduct:(SKProduct*)product;
- (IBAction)purchase:(id)sender;
@end
