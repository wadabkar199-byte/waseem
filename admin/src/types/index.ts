export type UserRole = 'client' | 'barber' | 'admin';

export type ShopStatus = 'pending_review' | 'approved' | 'suspended' | 'rejected';

export interface AdminStats {
  totalShops: number;
  pendingShops: number;
  totalBookings: number;
  totalRevenue: number;
  totalUsers: number;
}

export interface BarberShopAdminView {
  id: string;
  name: string;
  ownerName: string;
  ownerPhone: string;
  district: string;
  status: ShopStatus;
  createdAt: string;
  ratingAverage: number;
}

export interface ReportAdminView {
  id: string;
  reporterName: string;
  targetShopName: string;
  reason: string;
  status: string;
  createdAt: string;
}

export interface AuditLogItem {
  id: string;
  actorName: string;
  action: string;
  entityName: string;
  createdAt: string;
  details: string;
}
