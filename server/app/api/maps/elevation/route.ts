import { NextRequest, NextResponse } from 'next/server';

/**
 * GET /api/maps/elevation
 * Proxy endpoint for Google Maps Elevation API
 * Secures the Google Maps API key on the server side
 */
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const locations = searchParams.get('locations'); // lat,lng|lat,lng format

    // Validate request
    if (!locations) {
      return NextResponse.json(
        { success: false, error: 'Locations parameter is required' },
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
      locations,
      key: apiKey,
    });

    const url = `https://maps.googleapis.com/maps/api/elevation/json?${params.toString()}`;

    // Call Google Maps API
    const response = await fetch(url);

    if (!response.ok) {
      console.error('Google Maps Elevation API error:', response.statusText);
      return NextResponse.json(
        { success: false, error: 'Google Maps Elevation API request failed' },
        { status: response.status }
      );
    }

    const data = await response.json();

    if (data.status !== 'OK') {
      console.error('Google Maps Elevation API error status:', data.status);
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
    console.error('Error in elevation endpoint:', error);
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    );
  }
}
