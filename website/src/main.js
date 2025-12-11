import './style.css'

document.querySelector('#app').innerHTML = `
  <div class="min-h-screen bg-gradient-to-br from-indigo-500 via-purple-500 to-pink-500">
    <nav class="bg-white/10 backdrop-blur-md border-b border-white/20">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          <div class="flex items-center space-x-2">
            <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"></path>
            </svg>
            <span class="text-white text-xl font-bold">NotchPrompter</span>
          </div>
          <div class="hidden md:flex space-x-8">
            <a href="#features" class="text-white hover:text-gray-200 transition">Features</a>
            <a href="#download" class="text-white hover:text-gray-200 transition">Download</a>
            <a href="#about" class="text-white hover:text-gray-200 transition">About</a>
          </div>
        </div>
      </div>
    </nav>

    <main>
      <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 text-center">
        <h1 class="text-5xl md:text-7xl font-bold text-white mb-6">
          Professional Teleprompter<br/>for macOS
        </h1>
        <p class="text-xl md:text-2xl text-white/90 mb-12 max-w-3xl mx-auto">
          Utilize the Dynamic Island on your MacBook Pro for a seamless prompting experience. Perfect for content creators, presenters, and professionals.
        </p>
        <div class="flex flex-col sm:flex-row gap-4 justify-center">
          <button class="bg-white text-purple-600 px-8 py-4 rounded-lg font-semibold text-lg hover:bg-gray-100 transition shadow-lg">
            Download for macOS
          </button>
          <button class="bg-white/10 backdrop-blur-md text-white border-2 border-white/30 px-8 py-4 rounded-lg font-semibold text-lg hover:bg-white/20 transition">
            Learn More
          </button>
        </div>
      </section>

      <section id="features" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20">
        <h2 class="text-4xl font-bold text-white text-center mb-16">Features</h2>
        <div class="grid md:grid-cols-3 gap-8">
          <div class="bg-white/10 backdrop-blur-md border border-white/20 rounded-xl p-8 hover:bg-white/20 transition">
            <div class="w-12 h-12 bg-purple-500 rounded-lg flex items-center justify-center mb-4">
              <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
              </svg>
            </div>
            <h3 class="text-xl font-bold text-white mb-2">Dynamic Island Integration</h3>
            <p class="text-white/80">Seamlessly integrates with MacBook Pro's Dynamic Island for a unique prompting experience.</p>
          </div>
          
          <div class="bg-white/10 backdrop-blur-md border border-white/20 rounded-xl p-8 hover:bg-white/20 transition">
            <div class="w-12 h-12 bg-pink-500 rounded-lg flex items-center justify-center mb-4">
              <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"></path>
              </svg>
            </div>
            <h3 class="text-xl font-bold text-white mb-2">Customizable Speed</h3>
            <p class="text-white/80">Control scrolling speed and text size to match your reading pace perfectly.</p>
          </div>
          
          <div class="bg-white/10 backdrop-blur-md border border-white/20 rounded-xl p-8 hover:bg-white/20 transition">
            <div class="w-12 h-12 bg-indigo-500 rounded-lg flex items-center justify-center mb-4">
              <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
              </svg>
            </div>
            <h3 class="text-xl font-bold text-white mb-2">Script Management</h3>
            <p class="text-white/80">Import and manage multiple scripts with ease. Support for various text formats.</p>
          </div>
        </div>
      </section>

      <section id="download" class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-20 text-center">
        <div class="bg-white/10 backdrop-blur-md border border-white/20 rounded-2xl p-12">
          <h2 class="text-4xl font-bold text-white mb-6">Ready to get started?</h2>
          <p class="text-xl text-white/90 mb-8">Download NotchPrompter for macOS and transform your presentation workflow.</p>
          <button class="bg-white text-purple-600 px-10 py-5 rounded-lg font-semibold text-xl hover:bg-gray-100 transition shadow-lg">
            Download Now
          </button>
          <p class="text-white/70 mt-4">Compatible with macOS 13.0 and later</p>
        </div>
      </section>
    </main>

    <footer class="bg-white/5 backdrop-blur-md border-t border-white/10 mt-20">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div class="text-center text-white/70">
          <p>&copy; 2025 NotchPrompter. All rights reserved.</p>
        </div>
      </div>
    </footer>
  </div>
`