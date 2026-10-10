// ==============================================================================
// دالة الحافة السحابية لإرسال الإشعارات خادمياً عبر Firebase Cloud Messaging (FCM)
// منصة وسيم | WASEEM Edge Function
// ==============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

interface NotificationPayload {
  targetFcmToken: string;
  type: "booking_confirmed" | "new_booking_for_barber" | "reminder" | "cancelled";
  bookingReference: string;
  shopName: string;
  appointmentTime: string;
}

serve(async (req: Request) => {
  try {
    if (req.method !== "POST") {
      return new Response(JSON.stringify({ error: "Method not allowed" }), { status: 405 });
    }

    const payload: NotificationPayload = await req.json();
    const fcmServerKey = Deno.env.get("FCM_SERVER_KEY");

    if (!fcmServerKey) {
      return new Response(
        JSON.stringify({ error: "FCM_SERVER_KEY is not configured on Edge secrets" }),
        { status: 500 }
      );
    }

    // إعداد نص الإشعار العام (حماية شاشة القفل من تسريب البيانات الحساسة)
    let title = "تحديث حجز وسيم";
    let body = `حجز رقم: ${payload.bookingReference}`;

    switch (payload.type) {
      case "booking_confirmed":
        title = "تأكيد موعد الحلاقة";
        body = `تم تأكيد حجزك في ${payload.shopName} بنجاح. موعدك: ${payload.appointmentTime}`;
        break;
      case "new_booking_for_barber":
        title = "موعد حجز جديد";
        body = `لديك حجز جديد (${payload.bookingReference}) في تمام: ${payload.appointmentTime}`;
        break;
      case "reminder":
        title = "تذكير بموعدك القريب";
        body = `نذكرك بموعد حلاقتك القادم في ${payload.shopName} اليوم في ${payload.appointmentTime}`;
        break;
      case "cancelled":
        title = "إلغاء الموعد";
        body = `تم إلغاء الحجز رقم: ${payload.bookingReference}`;
        break;
    }

    // إرسال الإشعار لـ FCM
    const fcmResponse = await fetch("https://fcm.googleapis.com/fcm/send", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `key=${fcmServerKey}`,
      },
      body: JSON.stringify({
        to: payload.targetFcmToken,
        notification: {
          title,
          body,
          sound: "default",
          // إعدادات أمان الخصوصية لشاشة قفل الهاتف:
          visibility: "private", // لا تعرض المحتوى إذا كان الجهاز مقفلاً ومحمياً
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          booking_reference: payload.bookingReference,
          type: payload.type,
        },
      }),
    });

    const fcmResult = await fcmResponse.json();

    return new Response(JSON.stringify({ success: true, result: fcmResult }), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { "Content-Type": "application/json" },
      status: 500,
    });
  }
});
