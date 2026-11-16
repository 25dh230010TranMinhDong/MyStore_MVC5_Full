using System;
using System.Data.Entity;
using System.Linq;
using System.Web.Mvc;
using MyStore.Web.Models;
using MyStore.Web.Services;
namespace MyStore.Web.Controllers
{
    [Authorize]
    public class OrderController : Controller
    {
        private readonly MyStoreEntities db = new MyStoreEntities();
        private CartService Cart => new CartService(Session);
        private Customer CurrentCustomer() => db.Customers.FirstOrDefault(x=>x.Username==User.Identity.Name);
        [HttpGet]
        public ActionResult Checkout()
        {
            Cart.SyncPrices(db);var cart=Cart.GetCart();
            if(!cart.Items.Any(x=>x.Selected))return RedirectToAction("Index","Cart");
            var customer=CurrentCustomer();if(customer==null)return new HttpStatusCodeResult(403);
            return View(new CheckoutVM{ShippingAddress=customer.CustomerAddress,Items=cart.Items.Where(x=>x.Selected).ToList(),TotalAmount=cart.Total});
        }
        [HttpPost,ValidateAntiForgeryToken]
        public ActionResult Checkout(CheckoutVM vm)
        {
            Cart.SyncPrices(db);var cart=Cart.GetCart();
            vm.Items=cart.Items.Where(x=>x.Selected).ToList();vm.TotalAmount=cart.Total;
            var customer=CurrentCustomer();if(customer==null)return new HttpStatusCodeResult(403);
            if(!ModelState.IsValid)return View(vm);
            if(vm.PaymentMethod=="PayPal")
            {
                // Không giả mạo kết quả PayPal. Kích hoạt luồng sandbox REST riêng.
                Session["MyStore.PayPalCheckout"] = new CheckoutVM{
                    ShippingAddress=vm.ShippingAddress, PaymentMethod="PayPal", DeliveryMethod=vm.DeliveryMethod
                };
                return RedirectToAction("PaymentWithPaypal","Paypal");
            }
            try
            {
                var order=OrderService.Place(db,cart,customer,vm);
                Cart.RemovePurchased(order.OrderDetails.Select(x=>x.ProductID));
                return RedirectToAction("OrderSuccess",new{id=order.OrderID});
            }
            catch(InvalidOperationException e) {ModelState.AddModelError("",e.Message);return View(vm);}
        }
        public ActionResult OrderSuccess(int id)
        {
            var customer=CurrentCustomer();if(customer==null)return new HttpStatusCodeResult(403);
            var order=db.Orders.Include(x=>x.OrderDetails.Select(d=>d.Product))
                .FirstOrDefault(x=>x.OrderID==id&&x.CustomerID==customer.CustomerID);
            if(order==null)return HttpNotFound();return View(order);
        }
        public ActionResult MyOrder(string status,string keyword)
        {
            var customer=CurrentCustomer();if(customer==null)return new HttpStatusCodeResult(403);
            var q=db.Orders.Include(x=>x.OrderDetails.Select(d=>d.Product)).Where(x=>x.CustomerID==customer.CustomerID);
            if(!string.IsNullOrWhiteSpace(status))q=q.Where(x=>x.OrderStatus==status);
            if(!string.IsNullOrWhiteSpace(keyword))
            {
                var k=keyword.Trim();
                int id;if(int.TryParse(k,out id))q=q.Where(x=>x.OrderID==id||x.OrderDetails.Any(d=>d.Product.ProductName.Contains(k)));
                else q=q.Where(x=>x.OrderDetails.Any(d=>d.Product.ProductName.Contains(k)));
            }
            return View(new OrderHistoryVM{Status=status,Keyword=keyword,Orders=q.OrderByDescending(x=>x.OrderDate).ThenByDescending(x=>x.OrderID).ToList()});
        }
        public ActionResult OrderHistory(string status,string keyword)=>RedirectToAction("MyOrder",new{status,keyword});
        [HttpPost,ValidateAntiForgeryToken]
        public ActionResult Cancel(int id)
        {
            var customer=CurrentCustomer();if(customer==null)return new HttpStatusCodeResult(403);
            var order=db.Orders.FirstOrDefault(x=>x.OrderID==id&&x.CustomerID==customer.CustomerID);
            if(order==null)return HttpNotFound();
            try{OrderService.Cancel(db,order);TempData["Success"]="Đã hủy đơn và hoàn lại tồn kho.";}
            catch(InvalidOperationException e){TempData["Error"]=e.Message;}
            return RedirectToAction("MyOrder");
        }
        protected override void Dispose(bool disposing){if(disposing)db.Dispose();base.Dispose(disposing);}
    }
}
