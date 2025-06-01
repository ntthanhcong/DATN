const express = require("express");
const crypto = require("crypto");
const https = require("https");
const bodyParser = require("body-parser");
const cors = require("cors");

const app = express();
app.use(bodyParser.json());
app.use(cors());

const PORT = 3000; // bạn có thể thay đổi nếu cần

app.post("/create-payment", (req, res) => {
    const {
        amount,
        orderInfo,
        redirectUrl,
        ipnUrl,
        extraData = "",
    } = req.body;

    const partnerCode = "MOMO";
    const accessKey = "F8BBA842ECF85";
    const secretKey = "K951B6PE1waDMi640xX08PD3vg6EkVlz";
    const requestType = "captureWallet";
    const orderId = partnerCode + new Date().getTime();
    const requestId = orderId;
    const autoCapture = true;
    const lang = "vi";

    const rawSignature = `accessKey=${accessKey}&amount=${amount}&extraData=${extraData}&ipnUrl=${ipnUrl}&orderId=${orderId}&orderInfo=${orderInfo}&partnerCode=${partnerCode}&redirectUrl=${redirectUrl}&requestId=${requestId}&requestType=${requestType}`;

    const signature = crypto
        .createHmac("sha256", secretKey)
        .update(rawSignature)
        .digest("hex");

    const requestBody = JSON.stringify({
        partnerCode,
        partnerName: "Test",
        storeId: "MomoTestStore",
        requestId,
        amount,
        orderId,
        orderInfo,
        redirectUrl,
        ipnUrl,
        lang,
        requestType,
        autoCapture,
        extraData,
        signature,
    });

    const options = {
        hostname: "test-payment.momo.vn",
        port: 443,
        path: "/v2/gateway/api/create",
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "Content-Length": Buffer.byteLength(requestBody),
        },
    };

    const momoReq = https.request(options, (momoRes) => {
        let data = "";
        momoRes.on("data", (chunk) => {
            data += chunk;
        });
        momoRes.on("end", () => {
            const responseData = JSON.parse(data);
            console.log("✅ payUrl:", responseData.payUrl);
            res.status(200).json(responseData); // gửi về Flutter
        });
    });

    momoReq.on("error", (e) => {
        res.status(500).json({ error: e.message });
    });

    momoReq.write(requestBody);
    momoReq.end();
});
// app.get("/momo-result", async (req, res) => {
//     const { resultCode, orderId } = req.query;

//     if (resultCode === '0') {
//         // Giao dịch thành công
//         console.log(`✅ Thanh toán thành công cho đơn hàng ${orderId}`);
//         res.send(`
//             <html>
//               <body>
//                 <h2 style="color:green">🎉 Thanh toán thành công!</h2>
//                 <p>Đơn hàng: ${orderId}</p>
//               </body>
//             </html>
//         `);
//     } else {
//         // Giao dịch thất bại
//         console.log(`❌ Thanh toán thất bại cho đơn hàng ${orderId}, mã lỗi: ${resultCode}`);
//         res.send(`
//             <html>
//               <body>
//                 <h2 style="color:red">❌ Thanh toán thất bại</h2>
//                 <p>Đơn hàng: ${orderId}</p>
//                 <p>Mã lỗi: ${resultCode}</p>
//               </body>
//             </html>
//         `);
//     }
// });
app.listen(PORT, () => {
    console.log(`MoMo server is running at http://localhost:${PORT}`);
});
