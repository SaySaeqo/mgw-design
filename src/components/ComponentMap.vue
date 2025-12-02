<template>
  <div class="map-container" ref="containerRef" @mousedown="startDrag" @mousemove="drag" @mouseup="stopDrag" @mouseleave="stopDrag"
      @wheel="handleZoom">
      <div class="map-image" :style="{
        backgroundImage: `url(${backgroundImage})`,
        transform: `translate(${position.x}px, ${position.y}px) scale(${currentScale})`,
        width: imageSize.width + 'px',
        height: imageSize.height + 'px'
      }" ref="imageRef">
      </div>
      <!-- Clickable points -->
      <div v-for="(point, index) in points" :key="index" class="map-point" :style="{
        left: point.x * currentScale + position.x + 'px',
        top: point.y * currentScale + position.y + 'px',
      }" @click="handlePointClick(point)" :title="point.title || `Point ${index + 1}`">
        <div class="point-circle"></div>
        <div class="point-pulse"></div>
      </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch, defineProps, defineEmits } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

// Props
const props = defineProps({
  backgroundImage: {
    type: String,
    required: true
  },
  scale: {
    type: Number,
    default: 1,
    validator: (value) => value >= 1 && value <= 5
  },
  points: {
    type: Array,
    default: () => [],
    validator: (points) => {
      return points.every(point =>
        typeof point.x === 'number' &&
        typeof point.y === 'number' &&
        (point.link === undefined || typeof point.link === 'string')
      )
    }
  },
  minScale: {
    type: Number,
    default: 1
  },
  maxScale: {
    type: Number,
    default: 3
  }
})

// Emits
const emit = defineEmits(['pointClick'])

// Reactive data
const containerRef = ref(null)
const imageRef = ref(null)
const currentScale = ref(props.scale)
const isDragging = ref(false)
const dragStart = reactive({ x: 0, y: 0 })
const position = reactive({ x: 0, y: 0 })
const imageSize = reactive({ width: 800, height: 600 })

// Methods

const constrainPosition = (x, y) => {
  if (!containerRef.value) return { x, y }

  const containerRect = containerRef.value.getBoundingClientRect()
  const scaledWidth = imageSize.width * currentScale.value
  const scaledHeight = imageSize.height * currentScale.value

  // Calculate boundaries
  const minX = containerRect.width - scaledWidth
  const maxX = 0
  const minY = containerRect.height - scaledHeight
  const maxY = 0

  // Constrain position within boundaries
  const constrainedX = Math.max(minX, Math.min(maxX, x))
  const constrainedY = Math.max(minY, Math.min(maxY, y))

  return { x: constrainedX, y: constrainedY }
}

const startDrag = (event) => {
  isDragging.value = true
  dragStart.x = event.clientX - position.x
  dragStart.y = event.clientY - position.y
  document.body.style.cursor = 'grabbing'
}

const drag = (event) => {
  if (!isDragging.value) return

  event.preventDefault()
  const newX = event.clientX - dragStart.x
  const newY = event.clientY - dragStart.y

  // Apply constraints to prevent dragging beyond boundaries
  const constrained = constrainPosition(newX, newY)
  position.x = constrained.x
  position.y = constrained.y
}

const stopDrag = () => {
  isDragging.value = false
  document.body.style.cursor = 'default'
}

const handleZoom = (event) => {
  event.preventDefault()

  const delta = event.deltaY > 0 ? -0.2 : 0.2
  const newScale = Math.max(props.minScale, Math.min(props.maxScale, currentScale.value + delta))

  if (newScale !== currentScale.value) {
    // Calculate zoom center point
    const rect = containerRef.value.getBoundingClientRect()
    const centerX = (event.clientX - rect.left - position.x) / currentScale.value
    const centerY = (event.clientY - rect.top - position.y) / currentScale.value

    // Adjust position to zoom towards cursor
    const newX = event.clientX - rect.left - centerX * newScale
    const newY = event.clientY - rect.top - centerY * newScale

    // Apply constraints after zoom
    currentScale.value = newScale
    const constrained = constrainPosition(newX, newY)
    position.x = constrained.x
    position.y = constrained.y

  }
}

const handlePointClick = (point) => {
  emit('pointClick', point)

  if (point.link) {
    if (point.link.startsWith('http')) {
      // External link
      window.open(point.link, '_blank')
    } else {
      // Internal route
      // You can use router.push(point.link) if you have Vue Router
      router.push(point.link)
    }
  }
}

const loadImageDimensions = () => {
  const img = new Image();

  const setImageSize = () => {
    if (containerRef.value) {
      const containerRect = containerRef.value.getBoundingClientRect()
      imageSize.width = containerRect.width
      imageSize.height = containerRect.width * (img.naturalHeight / img.naturalWidth)

      const imgInitialScale = imageSize.width / img.naturalWidth;
      for (let point of props.points) {
        // Warn about points outside image bounds
        if (point.x < 0 || point.y < 0 || point.x > img.naturalWidth || point.y > img.naturalHeight) {
          console.warn(`Point (${point.x}, ${point.y}) is out of image bounds (${img.naturalWidth}, ${img.naturalHeight})`)
        }
        point.x = point.x * imgInitialScale
        point.y = point.y * imgInitialScale
      }
    } else {
      // wait for container to be available
      setTimeout(setImageSize, 100)
    }
  };
  img.onload = setImageSize;
  img.src = props.backgroundImage;
}

// Watch for scale changes
watch(() => props.scale, (newScale) => {
  currentScale.value = newScale
})

watch(() => props.backgroundImage, () => {
  loadImageDimensions()
})

// Lifecycle
onMounted(() => {
  loadImageDimensions()
})
</script>

<style scoped>
.map-container {
  overflow: hidden;
  position: relative;
  cursor: grab;
  border-radius: 8px;
  user-select: none;
}

.map-container:active {
  cursor: grabbing;
}

.map-image {
  background-size: contain;
  background-repeat: no-repeat;
  background-position: 0 0;
  position: relative;
  transform-origin: 0 0;
}

.map-point {
  position: absolute;
  transform: translate(-50%, -50%);
  cursor: pointer;
  z-index: 10;
}

.point-circle {
  width: 20px;
  height: 20px;
  background: #ff4444;
  border: 3px solid white;
  border-radius: 50%;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
}

.point-pulse {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 20px;
  height: 20px;
  background: rgba(255, 68, 68, 0.3);
  border-radius: 50%;
  animation: pulse 2s infinite;
}

.map-point:hover .point-circle {
  transform: scale(1.2);
  background: #ff6666;
}

@keyframes pulse {
  0% {
    transform: translate(-50%, -50%) scale(1);
    opacity: 1;
  }

  100% {
    transform: translate(-50%, -50%) scale(2.5);
    opacity: 0;
  }
}

/* Disable text selection during dragging */
.map-container * {
  -webkit-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none;
}
</style>
