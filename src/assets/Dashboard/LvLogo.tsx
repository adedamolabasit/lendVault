
import { SVGProps } from "react"
export const LvLogo = (props: SVGProps<SVGSVGElement>) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    xmlnsXlink="http://www.w3.org/1999/xlink"
    width={72}
    height={72}
    {...props}
    className="rounded-full"
  >
    <defs>
      <pattern id="b" width={1} height={1} patternContentUnits="userSpaceOnUse">
        <image
          width={768}
          height={1024}
          transform="matrix(.22787 0 0 .22787 0 -.081)"
        />
      </pattern>
    </defs>
    <defs>
      <clipPath id="a">
        <path d="M0 0h175v233.17H0V0Z" />
      </clipPath>
    </defs>
    <g clipPath="url(#a)">
      <path fill="url(#b)" d="M0 0h175v233.17H0z" />
    </g>
  </svg>
)