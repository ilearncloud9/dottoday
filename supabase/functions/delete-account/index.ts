// delete-account (docs/09 M6.5, 06 §6): Settings › Account › Delete account.
// The gateway checks the caller's JWT (verify_jwt); the service-role key
// is only ever here.
import { deleteAccount, resendMailer } from './deletion.ts';

const url = Deno.env.get('SUPABASE_URL')!;
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const resendKey = Deno.env.get('RESEND_API_KEY');
const mailFrom = Deno.env.get('ACCOUNT_MAIL_FROM');

Deno.serve(async (req) => {
  if (req.method !== 'POST') return new Response(null, { status: 405 });
  const jwt = req.headers.get('Authorization')?.replace(/^Bearer /, '') ?? null;
  const outcome = await deleteAccount(jwt, {
    url,
    serviceKey,
    fetch,
    sendMail: resendKey && mailFrom ? resendMailer(resendKey, mailFrom, fetch) : null,
  });
  if (outcome.status === 200 && !outcome.body.mailed) {
    console.warn('delete-account: no confirmation mail (RESEND_API_KEY / ACCOUNT_MAIL_FROM unset)');
  }
  return Response.json(outcome.body, { status: outcome.status });
});
