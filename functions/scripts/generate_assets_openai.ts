/**
 * Asset Generation Script (DALL-E 3)
 * 
 * Usage:
 * export OPENAI_API_KEY=sk-...
 * npx tsx scripts/generate_assets_openai.ts
 */

import * as fs from 'fs';
import * as path from 'path';
import * as https from 'https';
import { promisify } from 'util';

const wait = promisify(setTimeout);

// ============================================
// Configuration
// ============================================

const ASSETS_DIR = path.join(__dirname, '../../assets');

interface AssetConfig {
    path: string;
    prompt: string;
    size: string;
}

const MISSING_ASSETS: AssetConfig[] = [
    // Card Backs (350x500 approx, DALL-E 3 only does 1024x1024 or 1024x1792)
    {
        path: 'cards/backs/royal_back.png',
        prompt: 'Premium playing card back design, royal theme with gold crown emblem, deep purple velvet background with ornate gold filigree borders, elegant baroque patterns, luxury casino quality, high detail, symmetrical design',
        size: '1024x1792'
    },
    {
        path: 'cards/backs/dragon_back.png',
        prompt: 'Premium playing card back design, dragon theme with intricate red and gold Chinese dragon, dark crimson background with gold cloud patterns, ornate Asian-inspired borders, luxury quality, symmetrical design',
        size: '1024x1792'
    },
    {
        path: 'cards/backs/diamond_back.png',
        prompt: 'Premium playing card back design, diamond gem theme with large sparkling diamond in center, midnight blue background with geometric Art Deco patterns, silver metallic borders, luxury casino quality, symmetrical design',
        size: '1024x1792'
    },

    // Table Backgrounds
    {
        path: 'images/tables/table_wood.png',
        prompt: 'Top-down view of luxury polished dark wood gaming table surface, mahogany finish with subtle wood grain, vintage casino quality, warm lighting, high resolution texture for card game background',
        size: '1024x1024'
    },
    {
        path: 'images/tables/table_felt_green.png',
        prompt: 'Top-down view of premium emerald green casino felt with subtle texture, professional poker table quality, soft lighting gradient, high resolution texture for card game background',
        size: '1024x1024'
    },
    {
        path: 'images/tables/table_luxury.png',
        prompt: 'Top-down view of luxury black velvet gaming table surface with gold trim, geometric patterns, modern VIP casino style, high detail texture',
        size: '1024x1024'
    },

    // Bot Avatars
    {
        path: 'images/bots/trickmaster.png',
        prompt: 'Stylized cartoon avatar of a mischievous magician character, wearing a top hat with playing cards floating around, purple and gold color scheme, confident smirk, circular avatar format, game character portrait, high quality digital art',
        size: '1024x1024'
    },
    {
        path: 'images/bots/cardshark.png',
        prompt: 'Stylized cartoon avatar of a cool shark wearing sunglasses and a tuxedo, holding a royal flush, ocean blue background, sleek modern style, circular avatar format, game character portrait',
        size: '1024x1024'
    },
    {
        path: 'images/bots/luckydice.png',
        prompt: 'Stylized cartoon avatar of a chaotic jester character holding giant dice, colorful rainbow theme, energetic expression, dynamic pose, circular avatar format, game character portrait',
        size: '1024x1024'
    },
    {
        path: 'images/bots/deepthink.png',
        prompt: 'Stylized cartoon avatar of a futuristic robot with glowing blue eyes, calculating probability holograms, sci-fi theme, intelligent expression, circular avatar format, game character portrait',
        size: '1024x1024'
    },
    {
        path: 'images/bots/royalace.png',
        prompt: 'Stylized cartoon avatar of a regal lion wearing a crown and royal cape, holding a golden ace card, noble expression, red and gold theme, circular avatar format, game character portrait',
        size: '1024x1024'
    },

    // Chip Stacks
    {
        path: 'images/chips/stack_small.png',
        prompt: 'Small stack of 5 basic casino chips, red and white striped, 3D render, isometric view, transparent background style, high quality game asset',
        size: '1024x1024'
    },
    {
        path: 'images/chips/stack_medium.png',
        prompt: 'Medium stack of 20 casino chips, mixed colors (red, blue, green), 3D render, isometric view, transparent background style, high quality game asset',
        size: '1024x1024'
    },
    {
        path: 'images/chips/stack_large.png',
        prompt: 'Large massive pile of gold and black casino chips, high value, 3D render, isometric view, transparent background style, wealthy look, high quality game asset',
        size: '1024x1024'
    }
];

// ============================================
// Logic
// ============================================

const API_KEY = process.env.OPENAI_API_KEY;

if (!API_KEY) {
    console.error('❌ Error: OPENAI_API_KEY environment variable is missing.');
    console.error('Usage: export OPENAI_API_KEY=sk-... && npx tsx scripts/generate_assets_openai.ts');
    process.exit(1);
}

async function downloadImage(url: string, destPath: string) {
    return new Promise<void>((resolve, reject) => {
        const file = fs.createWriteStream(destPath);
        https.get(url, (response) => {
            response.pipe(file);
            file.on('finish', () => {
                file.close();
                resolve();
            });
        }).on('error', (err) => {
            fs.unlink(destPath, () => { });
            reject(err);
        });
    });
}

async function generateImage(asset: AssetConfig) {
    console.log(`🎨 Generating: ${asset.path}...`);

    try {
        const response = await fetch('https://api.openai.com/v1/images/generations', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${API_KEY}`
            },
            body: JSON.stringify({
                model: 'dall-e-3',
                prompt: asset.prompt,
                n: 1,
                size: asset.size
            })
        });

        if (!response.ok) {
            const error = await response.text();
            throw new Error(`OpenAI API Error: ${response.status} - ${error}`);
        }

        const data = await response.json();
        const imageUrl = data.data[0].url;

        const fullPath = path.join(ASSETS_DIR, asset.path);
        const dirName = path.dirname(fullPath);

        if (!fs.existsSync(dirName)) {
            fs.mkdirSync(dirName, { recursive: true });
        }

        await downloadImage(imageUrl, fullPath);
        console.log(`✅ Saved to: ${asset.path}`);

    } catch (error: any) {
        console.error(`❌ Failed to generate ${asset.path}:`, error.message);
    }
}

async function main() {
    console.log(`🚀 Starting generation of ${MISSING_ASSETS.length} assets...`);

    for (const asset of MISSING_ASSETS) {
        const fullPath = path.join(ASSETS_DIR, asset.path);
        if (fs.existsSync(fullPath)) {
            console.log(`⏩ Skipping existing: ${asset.path}`);
            continue;
        }

        await generateImage(asset);
        // Wait 2s to avoid aggressive rate limits specific to keys
        await wait(2000);
    }

    console.log('\n✨ Asset generation complete!');
}

main().catch(console.error);
