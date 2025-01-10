import { createClient, SupabaseClient } from "@supabase/supabase-js";
import dotenv from "dotenv";
import fs from "fs";
import { DateTime } from "luxon";

dotenv.config();

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_ANON_KEY;
const SUPABASE_ACCOUNT_EMAIL = process.env.SUPABASE_ACCOUNT_EMAIL;
const SUPABASE_ACCOUNT_PASSWORD = process.env.SUPABASE_ACCOUNT_PASSWORD;
const TOKEN_FILE = "token.txt";

const generateSupabaseClient = (): SupabaseClient => {
    if (!SUPABASE_URL || !SUPABASE_KEY) {
        throw new Error("Missing Supabase URL or key");
    }

    return createClient(SUPABASE_URL, SUPABASE_KEY);
};

interface AccessResponse {
    token: string;
    expiration: string;
}

const fetchAccessToken = async (
    client: SupabaseClient
): Promise<AccessResponse> => {
    if (!SUPABASE_ACCOUNT_EMAIL || !SUPABASE_ACCOUNT_PASSWORD) {
        throw new Error("Missing Supabase account email or password");
    }

    const { data, error } = await client.auth.signInWithPassword({
        email: SUPABASE_ACCOUNT_EMAIL,
        password: SUPABASE_ACCOUNT_PASSWORD,
    });

    if (error || !data?.session.access_token || !data?.session.expires_in) {
        throw new Error("Failed to fetch access token");
    }

    const { access_token, expires_in } = data.session;
    const expiration = DateTime.utc().plus({ seconds: expires_in }).toISO();

    return { token: access_token, expiration };
};

async function logout(client: SupabaseClient) {
    const { error } = await client.auth.signOut();

    if (error) {
        throw new Error(`Logout failed: ${error.message}`);
    }

    console.log("Logged out successfully.");
}

function saveToken(token: string, expiration: string) {
    const tokenData = `${token},${expiration}`;
    fs.writeFileSync(TOKEN_FILE, tokenData);
    console.log(`Token and expiration saved to ${TOKEN_FILE}`);
}

async function main() {
    try {
        console.log("Logging in...");
        const client: SupabaseClient = generateSupabaseClient();
        const { token, expiration } = await fetchAccessToken(client);
        console.log("Login successful.");

        saveToken(token, expiration);
        await logout(client);
    } catch (error) {
        console.error("Error:", error);
    }
}

main();
