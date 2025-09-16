let nodemailer;
try {
  // eslint-disable-next-line global-require
  nodemailer = require('nodemailer');
} catch (e) {
  console.warn('[email] nodemailer not installed yet – emails will be logged only');
}

function buildTransport() {
  if (!nodemailer) {
    return {
      // mock sendMail so server won't crash before deps installed
      // eslint-disable-next-line no-unused-vars
      sendMail: async (opts) => {
        console.log('[email mock] would send email:', {
          to: opts?.to,
          subject: opts?.subject,
          text: opts?.text
        });
        return { messageId: 'mock' };
      }
    };
  }
  if (process.env.SMTP_HOST) {
    return nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: parseInt(process.env.SMTP_PORT || '587', 10),
      secure: process.env.SMTP_SECURE === 'true',
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS
      }
    });
  }
  // Fallback: ethereal for dev
  return nodemailer.createTransport({
    host: 'smtp.ethereal.email',
    port: 587,
    auth: {
      user: process.env.ETHEREAL_USER || 'user@example.com',
      pass: process.env.ETHEREAL_PASS || 'password'
    }
  });
}

async function sendResetCodeEmail(toEmail, code, link) {
  const transporter = buildTransport();
  const appName = process.env.APP_NAME || 'Task Flow';
  const html = `
  <div style="font-family:Arial,sans-serif">
    <h2>${appName} Password Reset</h2>
    <p>Click the button below to reset your password. If the button doesn't work, use the code below manually.</p>
    <p>
      <a href="${link}" style="background:#635bff;color:#fff;padding:10px 16px;border-radius:6px;text-decoration:none;display:inline-block">Reset Password</a>
    </p>
    ${code ? `<p>Reset code: <strong style="font-size:18px;letter-spacing:3px">${code}</strong></p>` : ''}
    <p>This link and code will expire in 15 minutes.</p>
  </div>`;

  const info = await transporter.sendMail({
    from: process.env.MAIL_FROM || `${appName} <no-reply@taskflow.local>`,
    to: toEmail,
    subject: `${appName} password reset`,
    text: `Use this link to reset: ${link}${code ? `\nOr use code: ${code} (expires in 15 minutes).` : ''}`,
    html
  });

  return info;
}

module.exports = { sendResetCodeEmail };


