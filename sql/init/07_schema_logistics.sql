-- ============================================================
-- 物流ドメイン (Logistics)
-- テーブル数: 6
-- ============================================================

CREATE TABLE shipments (
    shipmentId         SERIAL PRIMARY KEY,
    orderId            INTEGER NOT NULL REFERENCES orders(orderId),
    shippingCarrierId  INTEGER NOT NULL REFERENCES shippingCarriers(shippingCarrierId),
    shippingMethodId   INTEGER NOT NULL REFERENCES shippingMethods(shippingMethodId),
    trackingNumber     VARCHAR(50),
    shipmentStatus     VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (shipmentStatus IN ('pending', 'picked', 'shipped', 'in_transit', 'delivered', 'returned', 'cancelled')),
    shippedAt          TIMESTAMP,
    deliveredAt        TIMESTAMP,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE shipments IS '出荷ヘッダ（配送業者・追跡番号）';

CREATE TABLE shipmentItems (
    shipmentItemId     SERIAL PRIMARY KEY,
    shipmentId         INTEGER NOT NULL REFERENCES shipments(shipmentId) ON DELETE CASCADE,
    orderItemId        INTEGER NOT NULL REFERENCES orderItems(orderItemId),
    quantity           INTEGER NOT NULL CHECK (quantity > 0),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (shipmentId, orderItemId)
);

COMMENT ON TABLE shipmentItems IS '出荷明細（注文明細との紐付け）';

CREATE TABLE shipmentTracking (
    shipmentTrackingId SERIAL PRIMARY KEY,
    shipmentId         INTEGER NOT NULL REFERENCES shipments(shipmentId) ON DELETE CASCADE,
    trackingStatus     VARCHAR(50) NOT NULL,
    trackingLocation   VARCHAR(200),
    eventAt            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE shipmentTracking IS '配送追跡イベント（ステータス・場所・日時）';

CREATE TABLE pickingLists (
    pickingListId      SERIAL PRIMARY KEY,
    warehouseId        INTEGER NOT NULL REFERENCES warehouseMaster(warehouseId),
    assignedEmployeeId INTEGER REFERENCES employees(employeeId),
    pickingStatus      VARCHAR(20) NOT NULL DEFAULT 'open'
        CHECK (pickingStatus IN ('open', 'in_progress', 'completed', 'cancelled')),
    priority           SMALLINT NOT NULL DEFAULT 5 CHECK (priority BETWEEN 1 AND 10),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completedAt        TIMESTAMP
);

COMMENT ON TABLE pickingLists IS 'ピッキングリスト（倉庫・担当者）';

CREATE TABLE pickingListItems (
    pickingListItemId  SERIAL PRIMARY KEY,
    pickingListId      INTEGER NOT NULL REFERENCES pickingLists(pickingListId) ON DELETE CASCADE,
    orderItemId        INTEGER NOT NULL REFERENCES orderItems(orderItemId),
    locationId         INTEGER REFERENCES locationMaster(locationId),
    quantityToPick     INTEGER NOT NULL CHECK (quantityToPick > 0),
    quantityPicked     INTEGER NOT NULL DEFAULT 0 CHECK (quantityPicked >= 0),
    pickStatus         VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (pickStatus IN ('pending', 'picked', 'short', 'skipped')),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (pickingListId, orderItemId)
);

COMMENT ON TABLE pickingListItems IS 'ピッキング明細（ロケーション・ピック数量）';

CREATE TABLE deliverySchedules (
    deliveryScheduleId SERIAL PRIMARY KEY,
    shipmentId         INTEGER NOT NULL REFERENCES shipments(shipmentId) ON DELETE CASCADE UNIQUE,
    deliveryTimeSlotId INTEGER NOT NULL REFERENCES deliveryTimeSlots(deliveryTimeSlotId),
    scheduledDate      DATE NOT NULL,
    deliveryStatus     VARCHAR(20) NOT NULL DEFAULT 'scheduled'
        CHECK (deliveryStatus IN ('scheduled', 'out_for_delivery', 'delivered', 'failed', 'rescheduled')),
    recipientName      VARCHAR(100),
    deliveryNotes      VARCHAR(200),
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE deliverySchedules IS '配送予定（時間帯・受取人）';
