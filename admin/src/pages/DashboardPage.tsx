import React, { useState, useEffect } from 'react';
import { adminService } from '../services/adminService';
import { AdminStats, BarberShopAdminView, AuditLogItem } from '../types';
import { 
  Building2, 
  CalendarCheck, 
  Clock, 
  DollarSign, 
  Users, 
  ShieldCheck, 
  FileText, 
  AlertTriangle,
  CheckCircle2,
  XCircle,
  LogOut
} from 'lucide-react';

export const DashboardPage: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'overview' | 'shops' | 'reports' | 'audit'>('overview');
  const [stats, setStats] = useState<AdminStats | null>(null);
  const [shops, setShops] = useState<BarberShopAdminView[]>([]);
  const [auditLogs, setAuditLogs] = useState<AuditLogItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    setLoading(true);
    const [s, sh, al] = await Promise.all([
      adminService.getOverviewStats(),
      adminService.getPendingShops(),
      adminService.getAuditLogs(),
    ]);
    setStats(s);
    setShops(sh);
    setAuditLogs(al);
    setLoading(false);
  };

  const handleApprove = async (id: string) => {
    try {
      await adminService.updateShopStatus(id, 'approved');
      setShops(shops.map(sh => sh.id === id ? { ...sh, status: 'approved' } : sh));
      alert('تم اعتماد الصالون بنجاح وسيظهر للعملاء في تطبيق وسيم');
    } catch {
      alert('تعذر الاعتماد: تحقق من صلاحيات الأدمن أو سياسات RLS');
    }
  };

  const handleReject = async (id: string) => {
    try {
      await adminService.updateShopStatus(id, 'rejected');
      setShops(shops.map(sh => sh.id === id ? { ...sh, status: 'rejected' } : sh));
      alert('تم رفض طلب الصالون');
    } catch {
      alert('تعذر التحديث: تحقق من الصلاحيات');
    }
  };

  return (
    <div style={{ display: 'flex', minHeight: '100vh' }}>
      {/* الشريط الجانبي Sidebar */}
      <aside style={{ width: '260px', backgroundColor: '#123D32', color: '#fff', padding: '24px 16px', display: 'flex', flexDirection: 'column' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '32px', padding: '0 8px' }}>
          <div style={{ width: '40px', height: '40px', borderRadius: '50%', backgroundColor: '#0D2C24', display: 'flex', alignItems: 'center', justifyContent: 'center', border: '1px solid #F0D49A' }}>
            <ShieldCheck color="#F0D49A" size={24} />
          </div>
          <div>
            <h2 style={{ fontSize: '18px', fontWeight: 'bold', color: '#F0D49A' }}>وسـيـم | WASEEM</h2>
            <p style={{ fontSize: '11px', color: '#ccc' }}>لوحة الإدارة المركزية</p>
          </div>
        </div>

        <nav style={{ display: 'flex', flexDirection: 'column', gap: '8px', flex: 1 }}>
          <button 
            onClick={() => setActiveTab('overview')}
            style={{ display: 'flex', alignItems: 'center', gap: '10px', padding: '12px 14px', borderRadius: '10px', border: 'none', backgroundColor: activeTab === 'overview' ? '#0D2C24' : 'transparent', color: activeTab === 'overview' ? '#F0D49A' : '#fff', cursor: 'pointer', fontSize: '14px', fontWeight: 'bold', textAlign: 'right', width: '100%' }}>
            <Building2 size={18} />
            المؤشرات العامة
          </button>
          <button 
            onClick={() => setActiveTab('shops')}
            style={{ display: 'flex', alignItems: 'center', gap: '10px', padding: '12px 14px', borderRadius: '10px', border: 'none', backgroundColor: activeTab === 'shops' ? '#0D2C24' : 'transparent', color: activeTab === 'shops' ? '#F0D49A' : '#fff', cursor: 'pointer', fontSize: '14px', fontWeight: 'bold', textAlign: 'right', width: '100%' }}>
            <Clock size={18} />
            طلبات الصالونات ({shops.filter(s => s.status === 'pending_review').length})
          </button>
          <button 
            onClick={() => setActiveTab('reports')}
            style={{ display: 'flex', alignItems: 'center', gap: '10px', padding: '12px 14px', borderRadius: '10px', border: 'none', backgroundColor: activeTab === 'reports' ? '#0D2C24' : 'transparent', color: activeTab === 'reports' ? '#F0D49A' : '#fff', cursor: 'pointer', fontSize: '14px', fontWeight: 'bold', textAlign: 'right', width: '100%' }}>
            <AlertTriangle size={18} />
            البلاغات والشكاوى
          </button>
          <button 
            onClick={() => setActiveTab('audit')}
            style={{ display: 'flex', alignItems: 'center', gap: '10px', padding: '12px 14px', borderRadius: '10px', border: 'none', backgroundColor: activeTab === 'audit' ? '#0D2C24' : 'transparent', color: activeTab === 'audit' ? '#F0D49A' : '#fff', cursor: 'pointer', fontSize: '14px', fontWeight: 'bold', textAlign: 'right', width: '100%' }}>
            <FileText size={18} />
            سجل التدقيق (Audit Logs)
          </button>
        </nav>

        <button style={{ display: 'flex', alignItems: 'center', gap: '10px', padding: '12px 14px', borderRadius: '10px', border: '1px solid #ff4d4f', backgroundColor: 'transparent', color: '#ff4d4f', cursor: 'pointer', fontSize: '14px', fontWeight: 'bold' }}>
          <LogOut size={18} />
          خروج
        </button>
      </aside>

      {/* المحتوى الرئيسي Main Content */}
      <main style={{ flex: 1, padding: '32px', backgroundColor: '#FAF8F5' }}>
        <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '28px' }}>
          <div>
            <h1 style={{ fontSize: '24px', fontWeight: 'bold', color: '#123D32' }}>
              {activeTab === 'overview' && 'لوحة المؤشرات والتحليلات'}
              {activeTab === 'shops' && 'مراجعة واعتماد صالونات الحلاقة'}
              {activeTab === 'reports' && 'إدارة البلاغات وملاحظات العملاء'}
              {activeTab === 'audit' && 'سجل التدقيق والعمليات الإدارية'}
            </h1>
            <p style={{ fontSize: '13px', color: '#6B7280' }}>نظام التحقق وفرض الصلاحيات عبر RLS</p>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', backgroundColor: '#fff', padding: '8px 16px', borderRadius: '10px', border: '1px solid #E5E7EB' }}>
            <span style={{ width: '10px', height: '10px', borderRadius: '50%', backgroundColor: '#10B981' }}></span>
            <span style={{ fontSize: '13px', fontWeight: 'bold' }}>مدير النظام (Admin)</span>
          </div>
        </header>

        {loading ? (
          <div>جارٍ تحميل البيانات...</div>
        ) : (
          <>
            {/* المؤشرات العامة */}
            {activeTab === 'overview' && stats && (
              <div>
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '16px', marginBottom: '32px' }}>
                  <div style={{ backgroundColor: '#fff', padding: '20px', borderRadius: '14px', border: '1px solid #E5E7EB' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', color: '#6B7280', fontSize: '13px', marginBottom: '8px' }}>
                      إجمالي الصالونات
                      <Building2 size={18} color="#123D32" />
                    </div>
                    <div style={{ fontSize: '24px', fontWeight: 'bold', color: '#123D32' }}>{stats.totalShops}</div>
                  </div>
                  <div style={{ backgroundColor: '#fff', padding: '20px', borderRadius: '14px', border: '1px solid #E5E7EB' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', color: '#6B7280', fontSize: '13px', marginBottom: '8px' }}>
                      الطلبات المعلقة
                      <Clock size={18} color="#F59E0B" />
                    </div>
                    <div style={{ fontSize: '24px', fontWeight: 'bold', color: '#F59E0B' }}>{stats.pendingShops}</div>
                  </div>
                  <div style={{ backgroundColor: '#fff', padding: '20px', borderRadius: '14px', border: '1px solid #E5E7EB' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', color: '#6B7280', fontSize: '13px', marginBottom: '8px' }}>
                      إجمالي الحجوزات
                      <CalendarCheck size={18} color="#10B981" />
                    </div>
                    <div style={{ fontSize: '24px', fontWeight: 'bold', color: '#10B981' }}>{stats.totalBookings}</div>
                  </div>
                  <div style={{ backgroundColor: '#fff', padding: '20px', borderRadius: '14px', border: '1px solid #E5E7EB' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', color: '#6B7280', fontSize: '13px', marginBottom: '8px' }}>
                      المستخدمين المسجلين
                      <Users size={18} color="#3B82F6" />
                    </div>
                    <div style={{ fontSize: '24px', fontWeight: 'bold', color: '#3B82F6' }}>{stats.totalUsers}</div>
                  </div>
                </div>
              </div>
            )}

            {/* مراجعة الصالونات */}
            {activeTab === 'shops' && (
              <div style={{ backgroundColor: '#fff', borderRadius: '16px', border: '1px solid #E5E7EB', overflow: 'hidden' }}>
                <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'right' }}>
                  <thead>
                    <tr style={{ backgroundColor: '#F9FAFB', borderBottom: '1px solid #E5E7EB' }}>
                      <th style={{ padding: '14px 16px', fontSize: '13px', color: '#6B7280' }}>اسم الصالون</th>
                      <th style={{ padding: '14px 16px', fontSize: '13px', color: '#6B7280' }}>المالك / الجوال</th>
                      <th style={{ padding: '14px 16px', fontSize: '13px', color: '#6B7280' }}>الحي والمنطقة</th>
                      <th style={{ padding: '14px 16px', fontSize: '13px', color: '#6B7280' }}>الحالة</th>
                      <th style={{ padding: '14px 16px', fontSize: '13px', color: '#6B7280' }}>الإجراء</th>
                    </tr>
                  </thead>
                  <tbody>
                    {shops.map(shop => (
                      <tr key={shop.id} style={{ borderBottom: '1px solid #E5E7EB' }}>
                        <td style={{ padding: '16px', fontWeight: 'bold' }}>{shop.name}</td>
                        <td style={{ padding: '16px', fontSize: '13px' }}>{shop.ownerName}<br/><span style={{ color: '#9CA3AF' }}>{shop.ownerPhone}</span></td>
                        <td style={{ padding: '16px', fontSize: '13px' }}>{shop.district}</td>
                        <td style={{ padding: '16px' }}>
                          <span style={{ 
                            padding: '4px 10px', 
                            borderRadius: '8px', 
                            fontSize: '12px', 
                            fontWeight: 'bold',
                            backgroundColor: shop.status === 'approved' ? '#D1FAE5' : '#FEF3C7',
                            color: shop.status === 'approved' ? '#065F46' : '#92400E'
                          }}>
                            {shop.status === 'approved' ? 'معتمد' : 'قيد المراجعة'}
                          </span>
                        </td>
                        <td style={{ padding: '16px' }}>
                          {shop.status === 'pending_review' ? (
                            <div style={{ display: 'flex', gap: '8px' }}>
                              <button 
                                onClick={() => handleApprove(shop.id)}
                                style={{ display: 'flex', alignItems: 'center', gap: '4px', padding: '6px 12px', backgroundColor: '#10B981', color: '#fff', border: 'none', borderRadius: '6px', cursor: 'pointer', fontSize: '12px', fontWeight: 'bold' }}>
                                <CheckCircle2 size={14} /> قبول
                              </button>
                              <button 
                                onClick={() => handleReject(shop.id)}
                                style={{ display: 'flex', alignItems: 'center', gap: '4px', padding: '6px 12px', backgroundColor: '#EF4444', color: '#fff', border: 'none', borderRadius: '6px', cursor: 'pointer', fontSize: '12px', fontWeight: 'bold' }}>
                                <XCircle size={14} /> رفض
                              </button>
                            </div>
                          ) : (
                            <span style={{ fontSize: '12px', color: '#10B981', fontWeight: 'bold' }}>جاهز ونشط</span>
                          )}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}

            {/* سجل التدقيق */}
            {activeTab === 'audit' && (
              <div style={{ backgroundColor: '#fff', borderRadius: '16px', border: '1px solid #E5E7EB', padding: '16px' }}>
                <h3 style={{ fontSize: '16px', fontWeight: 'bold', marginBottom: '16px' }}>العمليات المسجلة في Audit Logs (مفروضة بـ RLS للمدير فقط)</h3>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                  {auditLogs.map(log => (
                    <div key={log.id} style={{ padding: '14px', borderRadius: '10px', backgroundColor: '#FAF8F5', border: '1px solid #E5E7EB' }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '4px' }}>
                        <span style={{ fontWeight: 'bold', color: '#123D32' }}>{log.action}</span>
                        <span style={{ fontSize: '12px', color: '#9CA3AF' }}>{log.createdAt}</span>
                      </div>
                      <div style={{ fontSize: '13px', color: '#4B5563' }}>{log.details}</div>
                      <div style={{ fontSize: '11px', color: '#6B7280', marginTop: '6px' }}>المسؤول: {log.actorName} • الكيان: {log.entityName}</div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </>
        )}
      </main>
    </div>
  );
};
