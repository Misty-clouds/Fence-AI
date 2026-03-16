import { NextRequest, NextResponse } from 'next/server';

/**
 * GET /api/maps/places
 * Proxy endpoint for Google Maps Places API (Nearby Search)
 * Secures the Google Maps API key on the server side
 */
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const location = searchParams.get('location'); // lat,lng format
    const radius = searchParams.get('radius') || '5000';
    const type = searchParams.get('type'); // e.g., 'restaurant', 'school', 'hospital'
    const keyword = searchParams.get('keyword');

    // Validate request
    if (!location) {
      return NextResponse.json(
        { success: false, error: 'Location parameter is required (format: lat,lng)' },
        { status: 400 }
      );
    }

    // Get Google Maps API key from environment
    const apiKey = process.env.GOOGLE_MAPS_API_KEY;
    if (!apiKey) {
      console.error('GOOGLE_MAPS_API_KEY not configured');
      return NextResponse.json(
        { success: false, error: 'Google Maps API not configured' },
        { status: 500 }
      );
    }

    // Build Google Maps API URL
    const params = new URLSearchParams({
      location,
      radius,
      key: apiKey,
    });

    if (type) {
      params.append('type', type);
    }
    if (keyword) {
      params.append('keyword', keyword);
    }

    const url = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?${params.toString()}`;

    // Call Google Maps API
    const response = await fetch(url);

    if (!response.ok) {
      console.error('Google Maps Places API error:', response.statusText);
      return NextResponse.json(
        { success: false, error: 'Google Maps Places API request failed' },
        { status: response.status }
      );
    }

    const data = await response.json();

    if (data.status !== 'OK' && data.status !== 'ZERO_RESULTS') {
      console.error('Google Maps Places API error status:', data.status);
      return NextResponse.json(
        { success: false, error: data.error_message || data.status },
        { status: 400 }
      );
    }

    return NextResponse.json({
      success: true,
      data: data.results,
      status: data.status,
    });
  } catch (error) {
    console.error('Error in places endpoint:', error);
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    );
  }
}
