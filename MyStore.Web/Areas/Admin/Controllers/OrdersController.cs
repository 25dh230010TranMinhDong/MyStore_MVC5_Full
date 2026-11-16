using System;
using System.Data.Entity;
using System.Linq;
using System.Web.Mvc;
using MyStore.Web.Models;
using MyStore.Web.Services;
namespace MyStore.Web.Areas.Admin.Controllers
{
    [AdminOnly]
    public class OrdersController : Controller
    {
        readonly MyStoreEntities db=new MyStoreEntities();
        public ActionResult Index(string keyword,string status,int page=1)
        {
            if(page<1)return new HttpStatusCodeResult(400);
            var q=db.Orders.Include(x=>x.Customer).AsQueryable();
            if(!string.IsNullOrWhiteSpace(status))q=q.Where(x=>x.OrderStatus==status);
            if(!string.IsNullOrWhiteSpace(keyword))
            {
                int id;if(int.TryParse(keyword,out id))q=q.Where(x=>x.OrderID==id||x.Customer.CustomerName.Contains(keyword));
                else q=q.Where(x=>x.Customer.CustomerName.Contains(keyword));
            }
            ViewBag.Keyword=keyword;ViewBag.Status=status;ViewBag.Page=page;ViewBag.Total=q.Count();
            return View(q.OrderByDescending(x=>x.OrderID).Skip((page-1)*10).Take(10).ToList());
        }
        public ActionResult Details(int id)
        {
            var o=db.Orders.Include(x=>x.Customer).Include(x=>x.OrderDetails.Select(d=>d.Product)).FirstOrDefault(x=>x.OrderID==id);
            return o==null?(ActionResult)HttpNotFound():View(o);
        }
        [HttpPost,ValidateAntiForgeryToken]
        public ActionResult SetStatus(int id,string status)
        {
            var o=db.Orders.Find(id);if(o==null)return HttpNotFound();
            var allowed=new[]{"Pending","Processing","Shipping","Delivered"};
            if(!allowed.Contains(status))return new HttpStatusCodeResult(400);
            if(o.OrderStatus=="Cancelled"||o.OrderStatus=="Delivered")return new HttpStatusCodeResult(409,"Không thể thay đổi trạng thái đơn đã hoàn thành/hủy.");
            if(Array.IndexOf(allowed,status)<Array.IndexOf(allowed,o.OrderStatus))return new HttpStatusCodeResult(409,"Không thể quay ngược trạng thái đơn.");
            o.OrderStatus=status;db.SaveChanges();return RedirectToAction("Details",new{id});
        }
        [HttpPost,ValidateAntiForgeryToken]
        public ActionResult Cancel(int id)
        {
            var o=db.Orders.Find(id);if(o==null)return HttpNotFound();
            try{OrderService.Cancel(db,o);TempData["Success"]="Đã hủy và cộng lại tồn kho.";}
            catch(InvalidOperationException e){TempData["Error"]=e.Message;}
            return RedirectToAction("Details",new{id});
        }
        protected override void Dispose(bool disposing){if(disposing)db.Dispose();base.Dispose(disposing);}
    }
}
